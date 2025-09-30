import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/loading_provider.dart';
import '../../core/providers/error_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/responsive_extensions.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class PasswordResetModal extends StatefulWidget {
  final VoidCallback? onResetComplete;
  
  const PasswordResetModal({
    super.key,
    this.onResetComplete,
  });

  @override
  State<PasswordResetModal> createState() => _PasswordResetModalState();
}

class _PasswordResetModalState extends State<PasswordResetModal> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    final errorProvider = Provider.of<ErrorProvider>(context, listen: false);

    // Mostra loading
    loadingProvider.showLoading(message: 'Aggiornamento password in corso...');

    try {
      final success = await authProvider.resetPassword(
        _newPasswordController.text.trim(),
      );

      loadingProvider.hideLoading();

      if (success && mounted) {
        // Chiudi il modal e procedi
        widget.onResetComplete?.call();
      } else if (mounted) {
        // Mostra errore
        errorProvider.showError(
          message: authProvider.errorMessage ?? 'Errore durante l\'aggiornamento della password',
          onRetry: _handlePasswordReset,
        );
      }
    } catch (e) {
      loadingProvider.hideLoading();
      if (mounted) {
        errorProvider.handleException(e, onRetry: _handlePasswordReset);
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Inserisci la nuova password';
    }
    if (value!.length < 6) {
      return 'La password deve contenere almeno 6 caratteri';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Conferma la nuova password';
    }
    if (value != _newPasswordController.text) {
      return 'Le password non coincidono';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostra il modal solo se reset_password è true
        if (authProvider.currentUser?.resetPassword != true) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black54,
          child: Center(
            child: SingleChildScrollView(
              padding: context.responsivePadding(
                mobile: 20,
                tablet: 40,
                desktop: 60,
              ),
              child: ResponsiveLayout.constrainedContainer(
                context: context,
                maxWidth: 500,
                child: Card(
                  elevation: AppTheme.lightTheme.cardTheme.elevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding: context.responsivePadding(
                      mobile: 24,
                      tablet: 32,
                      desktop: 40,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          _buildHeader(),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          )),

                          // Info message
                          _buildInfoMessage(),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          )),

                          // New password field
                          CustomTextField(
                            controller: _newPasswordController,
                            label: 'Nuova Password',
                            obscureText: _obscureNewPassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            validator: _validatePassword,
                          ),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          )),

                          // Confirm password field
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Conferma Nuova Password',
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: _validateConfirmPassword,
                          ),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 32,
                            tablet: 36,
                            desktop: 40,
                          )),

                          // Reset button
                          Consumer<LoadingProvider>(
                            builder: (context, loadingProvider, child) {
                              return CustomButton(
                                text: 'Aggiorna Password',
                                onPressed: loadingProvider.isLoading ? null : _handlePasswordReset,
                                isLoading: loadingProvider.isLoading,
                                width: double.infinity,
                                height: context.responsive<double>(
                                  mobile: 48,
                                  tablet: 52,
                                  desktop: 56,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.responsive<double>(
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ).w),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Icon(
            Icons.security,
            size: context.responsive<double>(
              mobile: 36,
              tablet: 44,
              desktop: 48,
            ).w,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        Text(
          'Reset Password Richiesto',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: context.responsiveFontSize(
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: EdgeInsets.all(context.responsive<double>(
        mobile: 16,
        tablet: 18,
        desktop: 20,
      ).w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: context.responsive<double>(
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ).w,
          ),
          SizedBox(height: context.responsiveSpacing(
            mobile: 8,
            tablet: 10,
            desktop: 12,
          )),
          Text(
            'È necessario aggiornare la password prima di procedere. Scegli una nuova password sicura per il tuo account.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: context.responsiveFontSize(
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
              color: AppTheme.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
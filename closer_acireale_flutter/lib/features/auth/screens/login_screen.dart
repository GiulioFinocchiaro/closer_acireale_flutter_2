import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/error_provider.dart';
import '../../../core/providers/loading_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    final errorProvider = Provider.of<ErrorProvider>(context, listen: false);
    
    // Mostra loading
    loadingProvider.showLoginLoading();
    
    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      loadingProvider.hideLoading();

      if (success && mounted) {
        // La navigazione è gestita automaticamente dal router
        if (authProvider.hasSchoolPermissions) {
          context.go('/dashboard-schools');
        } else {
          context.go('/dashboard');
        }
      } else if (mounted) {
        // Gestione errore con il provider globale
        if (authProvider.errorMessage?.contains('401') == true) {
          errorProvider.showValidationError('Email o password errata.\nVerifica le credenziali inserite.');
        } else {
          errorProvider.showError(
            message: authProvider.errorMessage ?? 'Errore durante il login',
            onRetry: _handleLogin,
          );
        }
      }
    } catch (e) {
      loadingProvider.hideLoading();
      errorProvider.handleException(e, onRetry: _handleLogin);
    }
  }

  @override
  void initState() {
    super.initState();
    // Rimuovo il login automatico per sicurezza
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueIndigoGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: context.responsivePadding(
                mobile: 20,
                tablet: 40,
                desktop: 60,
              ),
              child: ResponsiveLayout.constrainedContainer(
                context: context,
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
                            mobile: 32,
                            tablet: 36,
                            desktop: 40,
                          )),

                          // Email field
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Inserisci la tua email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                return 'Inserisci un\'email valida';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          )),

                          // Password field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Inserisci la password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: context.responsiveSpacing(
                            mobile: 32,
                            tablet: 36,
                            desktop: 40,
                          )),

                          // Login button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return CustomButton(
                                text: 'Accedi',
                                onPressed: authProvider.isLoading ? null : _handleLogin,
                                isLoading: authProvider.isLoading,
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
        ),
      ),
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
            gradient: AppTheme.blueIndigoGradient,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.bar_chart,
            size: context.responsive<double>(
              mobile: 36,
              tablet: 44,
              desktop: 48,
            ).w,
            color: Colors.white,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(
          mobile: 16,
          tablet: 18,
          desktop: 20,
        )),
        Text(
          'Accedi',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: context.responsiveFontSize(
              mobile: 22,
              tablet: 26,
              desktop: 30,
            ),
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(
          mobile: 6,
          tablet: 8,
          desktop: 10,
        )),
        Text(
          'Sistema Gestione Closer Acireale',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: context.responsiveFontSize(
              mobile: 13,
              tablet: 15,
              desktop: 17,
            ),
            color: AppTheme.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
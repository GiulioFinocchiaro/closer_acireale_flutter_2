import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/providers/error_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';

class GlobalErrorModal extends StatelessWidget {
  const GlobalErrorModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ErrorProvider>(
      builder: (context, errorProvider, _) {
        if (!errorProvider.hasError) {
          return const SizedBox.shrink();
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isMobile(context) ? 20.w : 40.w,
            vertical: ResponsiveUtils.isMobile(context) ? 40.h : 60.h,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isMobile(context) ? double.infinity : 400.w,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 20.w : 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con icona
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Icon(
                    _getErrorIcon(errorProvider.errorType),
                    size: ResponsiveUtils.isMobile(context) ? 32.w : 40.w,
                    color: AppTheme.errorRed,
                  ),
                ),
                SizedBox(height: 20.h),

                // Titolo
                Text(
                  _getErrorTitle(errorProvider.errorType),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ).sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Messaggio
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      errorProvider.errorMessage,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ).sp,
                        color: AppTheme.textMedium,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Bottoni azione
                _buildActionButtons(context, errorProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ErrorProvider errorProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bottone principale
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (errorProvider.onRetry != null) {
                errorProvider.onRetry!();
              }
              errorProvider.clearError();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 4,
            ),
            child: Text(
              errorProvider.onRetry != null ? 'Riprova' : 'OK',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Bottone secondario se disponibile
        if (errorProvider.onSecondaryAction != null) ...[
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                errorProvider.onSecondaryAction!();
                errorProvider.clearError();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textMedium,
                side: BorderSide(color: AppTheme.borderLight),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                errorProvider.secondaryActionText ?? 'Annulla',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.validation:
        return Icons.warning;
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Problema di Connessione';
      case ErrorType.timeout:
        return 'Tempo Scaduto';
      case ErrorType.unauthorized:
        return 'Accesso Negato';
      case ErrorType.server:
        return 'Errore del Server';
      case ErrorType.validation:
        return 'Dati Non Validi';
      default:
        return 'Errore';
    }
  }
}
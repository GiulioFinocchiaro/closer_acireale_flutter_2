import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';

class TokenExpiredModal extends StatelessWidget {
  const TokenExpiredModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.showTokenExpiredModal) {
          return const SizedBox.shrink();
        }

        return WillPopScope(
          onWillPop: () async => false, // Impedisce la chiusura con back button
          child: Material(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.isMobile(context) ? double.infinity : 400.w,
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 24.w : 32.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icona di avviso
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppTheme.warningYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: ResponsiveUtils.isMobile(context) ? 40.w : 48.w,
                        color: AppTheme.warningYellow,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Titolo
                    Text(
                      'Sessione Scaduta',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 20,
                          tablet: 22,
                          desktop: 24,
                        ).sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Messaggio
                    Text(
                      'La tua sessione è scaduta per motivi di sicurezza. '
                      'Effettua nuovamente l\'accesso per continuare.',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 16,
                        ).sp,
                        color: AppTheme.textMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // Bottone di azione
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleReturnToLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Torna al Login',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ).sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleReturnToLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Nascondi il modal e fai logout completo
    authProvider.hideTokenExpiredModal();
    await authProvider.logout();
    
    if (context.mounted) {
      // Naviga al login e pulisci lo stack
      context.go('/login');
    }
  }
}
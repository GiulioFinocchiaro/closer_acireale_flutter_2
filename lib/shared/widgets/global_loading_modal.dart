import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/providers/loading_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';

class GlobalLoadingModal extends StatelessWidget {
  const GlobalLoadingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(
      builder: (context, loadingProvider, _) {
        if (!loadingProvider.isLoading) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.isMobile(context) ? 280.w : 320.w,
              ),
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 24.w : 32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicatore di caricamento personalizzato
                  SizedBox(
                    width: 50.w,
                    height: 50.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Titolo
                  Text(
                    loadingProvider.loadingTitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ).sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Messaggio di loading
                  if (loadingProvider.loadingMessage.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      loadingProvider.loadingMessage,
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
                  ],

                  // Progress bar se disponibile
                  if (loadingProvider.progress != null) ...[
                    SizedBox(height: 20.h),
                    Column(
                      children: [
                        Text(
                          '${(loadingProvider.progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: loadingProvider.progress,
                            backgroundColor: AppTheme.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                            minHeight: 6.h,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bottone cancella se presente
                  if (loadingProvider.onCancel != null) ...[
                    SizedBox(height: 20.h),
                    OutlinedButton(
                      onPressed: loadingProvider.onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMedium,
                        side: BorderSide(color: AppTheme.borderLight),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Annulla',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
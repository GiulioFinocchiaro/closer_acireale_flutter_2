import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppTheme.primaryBlue,
            side: BorderSide(color: backgroundColor ?? AppTheme.primaryBlue),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryBlue,
            foregroundColor: textColor ?? Colors.white,
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 4,
          );

    Widget button = isOutlined
        ? OutlinedButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: _buildButtonContent(),
          )
        : ElevatedButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: _buildButtonContent(),
          );

    if (width != null) {
      button = SizedBox(
        width: width,
        height: height ?? 48.h,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? AppTheme.primaryBlue : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
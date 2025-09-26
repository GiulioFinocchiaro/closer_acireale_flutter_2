import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;

  const CustomModal({
    Key? key,
    required this.title,
    required this.fields,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h), // distanza dai bordi dello schermo
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400.w, // larghezza massima
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              ...fields.map((f) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: f,
              )),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    TextButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      child: Text(cancelText!),
                    ),
                  ElevatedButton(
                    onPressed: onConfirm,
                    child: Text(confirmText),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmDeleteModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final String cancelText;
  final VoidCallback? onCancel;

  const ConfirmDeleteModal({
    Key? key,
    this.title = 'Conferma eliminazione',
    required this.message,
    this.confirmText = 'Elimina',
    required this.onConfirm,
    this.cancelText = 'Annulla',
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400.w, // larghezza massima uguale al CustomModal
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
                    color: Colors.redAccent),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    child: Text(cancelText),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: onConfirm,
                    child: Text(confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
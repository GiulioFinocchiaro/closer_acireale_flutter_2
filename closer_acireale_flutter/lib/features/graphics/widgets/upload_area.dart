import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_theme.dart';

class UploadArea extends StatefulWidget {
  final String? selectedFileName;
  final Function(Uint8List bytes, String fileName) onFilePicked;

  const UploadArea({
    super.key,
    this.selectedFileName,
    required this.onFilePicked,
  });

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  bool _isDragging = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.first;
        widget.onFilePicked(file.bytes!, file.name);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore selezione file: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella selezione del file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragging ? AppTheme.primaryBlue : AppTheme.borderLight,
            style: BorderStyle.solid,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: _isDragging ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48.w,
              color: _isDragging ? AppTheme.primaryBlue : AppTheme.textMedium,
            ),
            SizedBox(height: 8.h),
            if (widget.selectedFileName != null) ...[
              Text(
                'File selezionato:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textMedium,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.selectedFileName!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Clicca per selezionare il file',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textMedium,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'SVG, PNG, JPG, GIF, WEBP',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
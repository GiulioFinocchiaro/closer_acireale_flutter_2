import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/models/graphic_asset_model.dart';
import '../../../core/theme/app_theme.dart';

class GraphicPreviewDialog extends StatelessWidget {
  final GraphicAsset graphic;

  const GraphicPreviewDialog({
    super.key,
    required this.graphic,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(24.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600.w,
          maxHeight: 700.h,
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con bottone chiudi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      graphic.fileName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 24.w,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Metadati
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      label: 'Tipo',
                      value: graphic.asset_type,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _InfoChip(
                      label: 'ID',
                      value: graphic.id.toString(),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Descrizione
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descrizione:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      graphic.description.isNotEmpty 
                          ? graphic.description 
                          : 'Nessuna descrizione disponibile',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Preview immagine
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppTheme.borderLight),
                    color: Colors.grey[50],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: graphic.isImage
                        ? Image.network(
                            graphic.fullUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _ErrorPlaceholder(
                                message: 'Impossibile caricare l\'immagine',
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Caricamento in corso...',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFileIcon(graphic.asset_type),
                                  size: 64.w,
                                  color: AppTheme.textMedium,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'File ${graphic.asset_type.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Preview non disponibile per questo tipo di file',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.textLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String message;

  const _ErrorPlaceholder({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48.w,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
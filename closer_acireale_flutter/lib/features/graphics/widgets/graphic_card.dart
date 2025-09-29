import 'package:closer_acireale_flutter/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/models/graphic_asset_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

class GraphicCard extends StatelessWidget {
  final GraphicAsset graphic;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GraphicCard({
    super.key,
    required this.graphic,
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPreview,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border(
            top: BorderSide(color: AppTheme.primaryBlue, width: 4.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con titolo e ID
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          graphic.fileName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'ID: ${graphic.id}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Immagine preview
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
                        ? _buildImage(graphic)
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getFileIcon(graphic.asset_type),
                            size: 48.w,
                            color: AppTheme.textMedium,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            graphic.asset_type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Metadati
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Tipo: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          graphic.asset_type,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'Descrizione: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          graphic.description.isNotEmpty ? graphic.description : 'Nessuna descrizione',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textMedium,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Bottoni azioni
              Row(
                children: [
                  if (Provider.of<AuthProvider>(context, listen: false).checkPermissionFromUser('media.update_all'))
                    Expanded(
                      child: CustomButton(
                        text: 'Modifica',
                        icon: Icons.edit,
                        onPressed: () {
                          onEdit();
                        },
                        height: 32.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                    ),
                  if (Provider.of<AuthProvider>(context, listen: false).checkPermissionFromUser('media.delete_all'))
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomButton(
                        text: 'Elimina',
                        icon: Icons.delete,
                        onPressed: () {
                          onDelete();
                        },
                        backgroundColor: Colors.red,
                        height: 32.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(GraphicAsset graphic) {
    // Per il web, utilizziamo un approccio diverso per garantire la compatibilità
    if (kIsWeb) {
      // Per web: utilizziamo Image.network senza headers personalizzati che causano CORS
      return Image.network(
        graphic.fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Errore caricamento immagine web: $error');
          print('URL: ${graphic.fullUrl}');
          return _buildErrorWidget('Errore caricamento web');
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
      );
    } else {
      // Per desktop e mobile
      return Image.network(
        graphic.fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Errore caricamento immagine: $error');
          print('URL: ${graphic.fullUrl}');
          return _buildErrorWidget('Errore caricamento');
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
      );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 32.w,
            color: AppTheme.textMedium,
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
            : null,
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
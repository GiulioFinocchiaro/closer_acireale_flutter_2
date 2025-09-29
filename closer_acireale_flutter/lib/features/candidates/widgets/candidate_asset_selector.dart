import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/graphic_asset_model.dart';
import '../../../core/providers/graphics_provider.dart';

class CandidateAssetSelector extends StatefulWidget {
  const CandidateAssetSelector({super.key});

  @override
  State<CandidateAssetSelector> createState() => _CandidateAssetSelectorState();
}

class _CandidateAssetSelectorState extends State<CandidateAssetSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssets();
    });
  }

  void _loadAssets() {
    final provider = Provider.of<GraphicsProvider>(context, listen: false);
    provider.initialize().then((_) => provider.getGraphics());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleziona Foto Candidato',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
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
            Container(
              height: 2.h,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Grid delle immagini
            Expanded(
              child: Consumer<GraphicsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.w,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Errore nel caricamento delle grafiche',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            provider.errorMessage!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _loadAssets,
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filtra solo le immagini
                  final imageAssets = provider.graphics.where((asset) => asset.isImage).toList();

                  if (imageAssets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 64.w,
                            color: AppTheme.textMedium,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Nessuna immagine disponibile',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMedium,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Carica delle immagini nella sezione Grafiche prima di selezionarne una.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppTheme.textMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 3,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: imageAssets.length,
                    itemBuilder: (context, index) {
                      final asset = imageAssets[index];
                      return _buildAssetCard(asset);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(GraphicAsset asset) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(asset);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Preview dell'immagine
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
                    child: Image.network(
                      asset.fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 32.w,
                                color: AppTheme.textMedium,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Errore caricamento',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.textMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Nome/descrizione
              Text(
                asset.description.isNotEmpty ? asset.description : asset.fileName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 4.h),

              Text(
                asset.asset_type,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
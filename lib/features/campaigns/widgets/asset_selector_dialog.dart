import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/graphic_asset_model.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../core/constants/app_constants.dart';

class AssetSelectorDialog extends StatefulWidget {
  const AssetSelectorDialog({super.key});

  @override
  State<AssetSelectorDialog> createState() => _AssetSelectorDialogState();
}

class _AssetSelectorDialogState extends State<AssetSelectorDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssets();
    });
  }

  void _loadAssets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    
    campaignsProvider.fetchGraphicAssets(
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleziona un Asset',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppTheme.textMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Grid degli asset
            Expanded(
              child: Consumer<CampaignsProvider>(
                builder: (context, campaignsProvider, child) {
                  if (campaignsProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (campaignsProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.errorRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Errore nel caricamento',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.errorRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAssets,
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (campaignsProvider.graphicAssets.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nessun asset disponibile.',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: campaignsProvider.graphicAssets.length,
                    itemBuilder: (context, index) {
                      final asset = campaignsProvider.graphicAssets[index];
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
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(asset);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Preview del file
              Expanded(
                child: _buildAssetPreview(asset),
              ),
              
              const SizedBox(height: 12),
              
              // Nome/descrizione
              Text(
                asset.description.isNotEmpty ? asset.description : asset.fileName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetPreview(GraphicAsset asset) {
    if (asset.isImage) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            asset.fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFileIcon(asset.fileType);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      );
    } else {
      return _buildFileIcon(asset.fileType);
    }
  }

  Widget _buildFileIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'document':
        icon = Icons.description;
        color = AppTheme.primaryBlue;
        break;
      case 'video':
        icon = Icons.movie;
        color = AppTheme.errorRed;
        break;
      case 'audio':
        icon = Icons.audiotrack;
        color = AppTheme.warningYellow;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = AppTheme.textMedium;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            _getTypeLabel(type),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'document':
        return 'Documento';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      default:
        return 'File';
    }
  }
}
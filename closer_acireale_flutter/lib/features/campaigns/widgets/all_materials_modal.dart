import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/material_model.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'delete_confirm_dialog.dart';
import 'material_preview_dialog.dart';

class AllMaterialsModal extends StatelessWidget {
  final List<MaterialModal> materials;
  final int campaignId;

  const AllMaterialsModal({
    super.key,
    required this.materials,
    required this.campaignId,
  });

  void _showMaterialPreview(BuildContext context, MaterialModal material) {
    if (material.graphic.filePath != null) {
      showDialog(
        context: context,
        builder: (context) => MaterialPreviewDialog(
          title: material.material_name,
          filePath: material.graphic.filePath,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, MaterialModal material) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Elimina Materiale',
        content: 'Sei sicuro di voler eliminare il materiale "${material.material_name}"? Questa azione è irreversibile.',
        onConfirm: () => _deleteMaterial(context, material),
      ),
    );
  }

  Future<void> _deleteMaterial(BuildContext context, MaterialModal material) async {
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);

    final success = await campaignsProvider.deleteMaterial(
      materialId: material.id,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materiale eliminato con successo'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Chiudi la modal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(campaignsProvider.error ?? 'Errore durante l\'eliminazione'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMaterialDetails(BuildContext context, MaterialModal material) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dettagli Materiale',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
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
              
              // Dettagli
              _buildDetailRow('Nome:', material.material_name),
              const SizedBox(height: 12),
              _buildDetailRow('Descrizione:', material.graphic.description),
              const SizedBox(height: 12),
              _buildDetailRow('Tipo:', material.graphic.asset_type),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Data Pubblicazione:', 
                material.published_at != null 
                  ? DateFormat('dd/MM/yyyy HH:mm').format(material.published_at!)
                  : 'Non programmata'
              ),
              
              const SizedBox(height: 24),
              
              // Azioni
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (material.graphic.filePath != null) ...[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showMaterialPreview(context, material);
                      },
                      child: const Text('Visualizza'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textMedium,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tutti i Materiali (${materials.length})',
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
            
            // Lista materiali
            Expanded(
              child: materials.isEmpty 
                ? const Center(
                    child: Text(
                      'Nessun materiale disponibile.',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGray,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Anteprima
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(material.graphic.asset_type),
                                color: AppTheme.primaryBlue,
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Info materiale
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.material_name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    material.graphic.description,
                                    style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pubblicazione: ${material.published_at != null ? DateFormat('dd/MM/yyyy').format(material.published_at!) : 'Non programmata'}',
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Azioni
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showMaterialDetails(context, material),
                                  icon: const Icon(Icons.info_outline),
                                  color: AppTheme.primaryBlue,
                                  tooltip: 'Dettagli',
                                ),
                                if (material.graphic.filePath != null)
                                  IconButton(
                                    onPressed: () => _showMaterialPreview(context, material),
                                    icon: const Icon(Icons.visibility),
                                    color: AppTheme.successGreen,
                                    tooltip: 'Visualizza',
                                  ),
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(context, material),
                                  icon: const Icon(Icons.delete_outline),
                                  color: AppTheme.errorRed,
                                  tooltip: 'Elimina',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Chiudi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'immagine':
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_camera_back;
      case 'documento':
      case 'document':
      case 'pdf':
        return Icons.description;
      default:
        return Icons.file_present;
    }
  }
}
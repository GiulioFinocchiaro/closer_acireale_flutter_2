import 'package:closer_acireale_flutter/core/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';
import '../../../core/constants/app_constants.dart';
import 'material_preview_dialog.dart';
import 'all_materials_modal.dart';

class MaterialSection extends StatelessWidget {
  final List<MaterialModal> materials;
  final VoidCallback? onAddMaterial;
  final int? campaignId;

  const MaterialSection({
    super.key,
    required this.materials,
    this.onAddMaterial,
    this.campaignId,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materiali Recenti',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Lista materiali
          if (materials.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nessun materiale disponibile.',
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...materials.take(3).map((material) => _buildMaterialItem(context, material)),
          
          const SizedBox(height: 24),
          
          // Bottone aggiungi
          if (onAddMaterial != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddMaterial,
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi Materiale'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          
          // Link "Vedi tutti"
          if (materials.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implementare pagina "Vedi tutti i materiali"
                },
                child: Text(
                  'Vedi tutti i ${materials.length} materiali',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(BuildContext context, MaterialModal material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome materiale
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textMedium,
                    ),
                    children: [
                      TextSpan(
                        text: '${material.material_name}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      TextSpan(text: material.graphic.description),
                    ],
                  ),
                ),
                
                // Data pubblicazione
                if (material.published_at != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Pubblicare il: ${material.published_at != null ? DateFormat('dd/MM/yyyy').format(material.published_at!) : '-'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Bottoni azione
          Row(
            children: [
              if (material.graphic.filePath != null)
                TextButton(
                  onPressed: () => _showMaterialPreview(context, material),
                  child: const Text(
                    'Visualizza',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              // TODO: Aggiungere bottone elimina con permessi
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr); // converte stringa in DateTime
      return DateFormat('dd/MM/yyyy').format(dateTime); // formato desiderato
    } catch (e) {
      return dateStr; // se fallisce, ritorna la stringa originale
    }
  }
}
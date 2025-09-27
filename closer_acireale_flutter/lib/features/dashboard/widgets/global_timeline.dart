import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../core/models/material_model.dart';
import '../../../core/models/event_model.dart';

class GlobalTimeline extends StatelessWidget {
  const GlobalTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                'Timeline Campagne Attive',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.timeline,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Timeline content
          Consumer<SchoolsProvider>(
            builder: (context, schoolsProvider, child) {
              return _buildTimelineContent(context, schoolsProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent(BuildContext context, SchoolsProvider schoolsProvider) {
    // Simulo alcuni eventi di timeline globale
    // In una implementazione reale, dovresti avere un metodo nel provider
    // che restituisce eventi e materiali di tutte le campagne attive
    
    final globalItems = _buildGlobalTimelineItems(schoolsProvider);
    
    if (globalItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.timeline,
                size: 48,
                color: AppTheme.textMedium,
              ),
              SizedBox(height: 16),
              Text(
                'Nessun evento futuro programmato',
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: globalItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == globalItems.length - 1;

        return _buildTimelineItem(context, item, !isLast);
      }).toList(),
    );
  }

  List<GlobalTimelineItem> _buildGlobalTimelineItems(SchoolsProvider schoolsProvider) {
    final items = <GlobalTimelineItem>[];
    final today = DateTime.now();

    // Aggiungi alcuni eventi di esempio basati sui dati del provider
    // In una implementazione reale, dovresti iterare attraverso tutte le campagne attive
    
    // Esempi di materiali futuri
    final materials = schoolsProvider.lastestMaterialSingleSchool ?? [];
    for (final material in materials) {
      if (material is MaterialModal && material.published_at != null) {
        if (material.published_at!.isAfter(today)) {
          items.add(GlobalTimelineItem(
            id: 'material_${material.id}',
            date: material.published_at!,
            title: material.material_name,
            description: material.graphic.description,
            type: GlobalTimelineItemType.material,
            campaignName: 'Campagna Esempio', // Dovresti avere il nome reale della campagna
          ));
        }
      }
    }

    // Aggiungi alcuni eventi di esempio
    // Questi dovrebbero venire dal provider in una implementazione reale
    if (items.isEmpty) {
      // Aggiungi eventi di esempio se non ci sono dati reali
      final exampleEvents = _getExampleEvents();
      items.addAll(exampleEvents);
    }

    // Ordina per data
    items.sort((a, b) => a.date.compareTo(b.date));
    return items.take(10).toList(); // Mostra solo i prossimi 10 eventi
  }

  List<GlobalTimelineItem> _getExampleEvents() {
    final now = DateTime.now();
    return [
      GlobalTimelineItem(
        id: 'example_1',
        date: now.add(const Duration(days: 2)),
        title: 'Pubblicazione Manifesto Elettorale',
        description: 'Pubblicazione ufficiale dei manifesti dei candidati',
        type: GlobalTimelineItemType.material,
        campaignName: 'Elezioni Rappresentanti 2024',
      ),
      GlobalTimelineItem(
        id: 'example_2',
        date: now.add(const Duration(days: 5)),
        title: 'Dibattito Candidati',
        description: 'Incontro pubblico con i candidati per le elezioni',
        type: GlobalTimelineItemType.event,
        campaignName: 'Elezioni Rappresentanti 2024',
      ),
      GlobalTimelineItem(
        id: 'example_3',
        date: now.add(const Duration(days: 10)),
        title: 'Apertura Seggi Elettorali',
        description: 'Inizio delle votazioni per le elezioni studentesche',
        type: GlobalTimelineItemType.event,
        campaignName: 'Elezioni Rappresentanti 2024',
      ),
    ];
  }

  Widget _buildTimelineItem(BuildContext context, GlobalTimelineItem item, bool showLine) {
    final isMaterial = item.type == GlobalTimelineItemType.material;
    final color = isMaterial ? AppTheme.primaryBlue : AppTheme.warningYellow;
    final icon = isMaterial ? Icons.description : Icons.event;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: AppTheme.borderLight,
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data e campagna
                  Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(item.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.campaignName,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Titolo
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Descrizione
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Bottone per maggiori dettagli
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showItemDetails(context, item),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Maggiori dettagli',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, GlobalTimelineItem item) {
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
                      'Dettagli Timeline',
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
              _buildDetailRow('Campagna:', item.campaignName),
              const SizedBox(height: 12),
              _buildDetailRow('Tipo:', item.type == GlobalTimelineItemType.material ? 'Materiale' : 'Evento'),
              const SizedBox(height: 12),
              _buildDetailRow('Titolo:', item.title),
              const SizedBox(height: 12),
              _buildDetailRow('Descrizione:', item.description),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Data:', 
                DateFormat('EEEE d MMMM y \'alle\' HH:mm', 'it_IT').format(item.date)
              ),
              
              const SizedBox(height: 24),
              
              // Azioni
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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
}

class GlobalTimelineItem {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final GlobalTimelineItemType type;
  final String campaignName;

  GlobalTimelineItem({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.campaignName,
  });
}

enum GlobalTimelineItemType { material, event }
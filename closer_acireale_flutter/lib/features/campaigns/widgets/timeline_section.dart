import 'package:closer_acireale_flutter/core/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/event_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';

class TimelineSection extends StatelessWidget {
  final List<MaterialModal> materials;
  final List<Event> events;

  const TimelineSection({
    super.key,
    required this.materials,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final timelineItems = _buildTimelineItems();

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
          Text(
            'Timeline della Campagna',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Timeline
          if (timelineItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nessun evento futuro pianificato.',
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            _buildTimeline(context, timelineItems),
        ],
      ),
    );
  }

  List<TimelineItem> _buildTimelineItems() {
    final today = DateTime.now();
    final items = <TimelineItem>[];

    // Aggiungi materiali futuri
    for (final material in materials) {
      if (material.published_at != null) {
        try {
          DateTime? date = material.published_at;
          if (date!.isAfter(today)) {
            items.add(TimelineItem(
              date: date,
              title: material.material_name,
              description: material.graphic.description,
              type: TimelineItemType.material,
            ));
          }
        } catch (e) {
          // Ignora date non valide
        }
      }
    }

    // Aggiungi eventi futuri
    for (final event in events) {
      if (event.eventDate != null) {
        try {
          final date = DateTime.parse(event.eventDate!);
          if (date.isAfter(today)) {
            items.add(TimelineItem(
              date: date,
              title: event.eventName,
              description: event.eventDescription,
              type: TimelineItemType.event,
              link: event.link,
            ));
          }
        } catch (e) {
          // Ignora date non valide
        }
      }
    }

    // Ordina per data
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Widget _buildTimeline(BuildContext context, List<TimelineItem> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return _buildTimelineItem(context, item, !isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineItem(BuildContext context, TimelineItem item, bool showLine) {
    final isMaterial = item.type == TimelineItemType.material;
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
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
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data
                  Text(
                    DateFormat('dd/MM/yyyy').format(item.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
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
                  
                  const SizedBox(height: 4),
                  
                  // Descrizione
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMedium,
                    ),
                  ),
                  
                  // Link o dettagli
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showItemDetails(context, item),
                    child: const Text(
                      'Maggiori informazioni',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
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

  void _showItemDetails(BuildContext context, TimelineItem item) {
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
                      item.type == TimelineItemType.material ? 'Dettagli Materiale' : 'Dettagli Evento',
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
              
              // Icona e tipo
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.type == TimelineItemType.material 
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : AppTheme.warningYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.type == TimelineItemType.material ? Icons.description : Icons.event,
                      color: item.type == TimelineItemType.material 
                        ? AppTheme.primaryBlue 
                        : AppTheme.warningYellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.type == TimelineItemType.material ? 'Materiale' : 'Evento',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Dettagli
              _buildDetailRow('Titolo:', item.title),
              const SizedBox(height: 12),
              _buildDetailRow('Descrizione:', item.description),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Data:', 
                DateFormat('EEEE d MMMM y \'alle\' HH:mm', 'it_IT').format(item.date)
              ),
              if (item.link != null && item.link!.isNotEmpty && item.link != '#') ...[
                const SizedBox(height: 12),
                _buildDetailRow('Link:', item.link!),
              ],
              
              const SizedBox(height: 24),
              
              // Azioni
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.link != null && item.link!.isNotEmpty && item.link != '#') ...[
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Aprire link
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Apri Link'),
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

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr); // converte stringa in DateTime
      return DateFormat('dd/MM/yyyy').format(dateTime); // formato desiderato
    } catch (e) {
      return dateStr; // se fallisce, ritorna la stringa originale
    }
  }
}

class TimelineItem {
  final DateTime date;
  final String title;
  final String description;
  final TimelineItemType type;
  final String? link;

  TimelineItem({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.link,
  });
}

enum TimelineItemType { material, event }
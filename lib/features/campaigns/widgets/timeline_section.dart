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
                  
                  // Link
                  if (item.link != null && item.link != '#') ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Aprire link
                      },
                      child: const Text(
                        'Visualizza',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/event_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';
import 'all_events_modal.dart';

class EventSection extends StatelessWidget {
  final List<Event> events;
  final VoidCallback? onAddEvent;

  const EventSection({
    super.key,
    required this.events,
    this.onAddEvent,
  });

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
          Text(
            'Eventi in Programma',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Lista eventi
          if (events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nessun evento disponibile.',
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...events.take(3).map((event) => _buildEventItem(context, event)),
          
          const SizedBox(height: 24),
          
          // Bottone aggiungi
          if (onAddEvent != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddEvent,
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi Evento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          
          // Link "Vedi tutti"
          if (events.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implementare pagina "Vedi tutti gli eventi"
                },
                child: Text(
                  'Vedi tutti i ${events.length} eventi',
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

  Widget _buildEventItem(BuildContext context, Event event) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome e descrizione evento
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMedium,
              ),
              children: [
                TextSpan(
                  text: '${event.eventName}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextSpan(text: event.eventDescription),
              ],
            ),
          ),
          
          // Dettagli evento
          if (event.location != null) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                ),
                children: [
                  const TextSpan(
                    text: 'Location: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: event.location),
                ],
              ),
            ),
          ],
          
          // Data evento
          if (event.eventDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'In data: ${_formatDate(event.eventDate!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
          
          // TODO: Aggiungere bottone elimina con permessi
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE d MMMM y', 'it_IT').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
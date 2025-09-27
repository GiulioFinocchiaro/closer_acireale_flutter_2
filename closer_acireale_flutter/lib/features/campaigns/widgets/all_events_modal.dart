import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/event_model.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'delete_confirm_dialog.dart';

class AllEventsModal extends StatelessWidget {
  final List<Event> events;
  final int campaignId;

  const AllEventsModal({
    super.key,
    required this.events,
    required this.campaignId,
  });

  void _showDeleteConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Elimina Evento',
        content: 'Sei sicuro di voler eliminare l\'evento "${event.eventName}"? Questa azione è irreversibile.',
        onConfirm: () => _deleteEvent(context, event),
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context, Event event) async {
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);

    final success = await campaignsProvider.deleteEvent(
      eventId: event.id,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento eliminato con successo'),
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

  void _showEventDetails(BuildContext context, Event event) {
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
                      'Dettagli Evento',
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
              _buildDetailRow('Nome:', event.eventName),
              const SizedBox(height: 12),
              _buildDetailRow('Descrizione:', event.eventDescription),
              const SizedBox(height: 12),
              if (event.location != null && event.location!.isNotEmpty) ...[
                _buildDetailRow('Location:', event.location!),
                const SizedBox(height: 12),
              ],
              _buildDetailRow(
                'Data:', 
                event.eventDate != null 
                  ? _formatDate(event.eventDate!)
                  : 'Non specificata'
              ),
              if (event.link != null && event.link!.isNotEmpty && event.link != '#') ...[
                const SizedBox(height: 12),
                _buildDetailRow('Link:', event.link!),
              ],
              
              const SizedBox(height: 24),
              
              // Azioni
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (event.link != null && event.link!.isNotEmpty && event.link != '#') ...[
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE d MMMM y \'alle\' HH:mm', 'it_IT').format(date);
    } catch (e) {
      return dateString;
    }
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
                  'Tutti gli Eventi (${events.length})',
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
            
            // Lista eventi
            Expanded(
              child: events.isEmpty 
                ? const Center(
                    child: Text(
                      'Nessun evento disponibile.',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
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
                            // Icona evento
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.warningYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: AppTheme.warningYellow,
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Info evento
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.eventName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.eventDescription,
                                    style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (event.eventDate != null)
                                    Text(
                                      'Data: ${_formatDate(event.eventDate!)}',
                                      style: const TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (event.location != null && event.location!.isNotEmpty)
                                    Text(
                                      'Location: ${event.location}',
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
                                  onPressed: () => _showEventDetails(context, event),
                                  icon: const Icon(Icons.info_outline),
                                  color: AppTheme.primaryBlue,
                                  tooltip: 'Dettagli',
                                ),
                                if (event.link != null && event.link!.isNotEmpty && event.link != '#')
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Aprire link
                                    },
                                    icon: const Icon(Icons.open_in_new),
                                    color: AppTheme.successGreen,
                                    tooltip: 'Apri Link',
                                  ),
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(context, event),
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
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = campaign.status == 'activate';
    final statusColor = isActive ? AppTheme.successGreen : AppTheme.warningYellow;
    final statusText = isActive ? 'Attiva' : 'Bozza';

    return Card(
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: statusColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con titolo e stato
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Descrizione
                Text(
                  campaign.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMedium,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Data di creazione
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Creata il ${_formatDate(campaign.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Statistiche
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Eventi: ${campaign.eventsCount} | Materiali: ${campaign.materialsCount} | Candidati: ${campaign.candidatesCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bottoni di azione
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null) ...[
                      IconButton(
                        onPressed: () {
                          onEdit!();
                        },
                        icon: const Icon(Icons.edit),
                        color: AppTheme.primaryBlue,
                        tooltip: 'Modifica',
                      ),
                    ],
                    if (onDelete != null) ...[
                      IconButton(
                        onPressed: () {
                          onDelete!();
                        },
                        icon: const Icon(Icons.delete),
                        color: AppTheme.errorRed,
                        tooltip: 'Elimina',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
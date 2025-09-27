import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/candidate_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';
import '../../../core/providers/candidates_provider.dart';
import '../../candidates/widgets/candidate_form_modal.dart';
import 'delete_confirm_dialog.dart';

class CandidatesSection extends StatelessWidget {
  final List<Candidate> candidates;
  final int? campaignId;
  final VoidCallback? onCandidatesChanged;

  const CandidatesSection({
    super.key,
    required this.candidates,
    this.campaignId,
    this.onCandidatesChanged,
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
            'Candidati della Campagna',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Lista candidati
          if (candidates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nessun candidato associato a questa campagna.',
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...candidates.map((candidate) => _buildCandidateItem(context, candidate)),
        ],
      ),
    );
  }

  Widget _buildCandidateItem(BuildContext context, Candidate candidate) {
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
          // Avatar
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              candidate.userName.isNotEmpty 
                ? candidate.userName[0].toUpperCase() 
                : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info candidato
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.userName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (candidate.classYear != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Classe: ${candidate.classYear}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
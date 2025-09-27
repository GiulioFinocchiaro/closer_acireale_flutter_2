import 'package:closer_acireale_flutter/core/models/campaign_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/material_section.dart';
import '../widgets/event_section.dart';
import '../widgets/candidates_section.dart';
import '../widgets/timeline_section.dart';
import '../widgets/add_material_modal.dart';
import '../widgets/add_event_modal.dart';

class SingleCampaignScreen extends StatefulWidget {
  late int campaignId;

  @override
  State<SingleCampaignScreen> createState() => _SingleCampaignScreenState();
}

class _SingleCampaignScreenState extends State<SingleCampaignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCampaignDetails();
    });
  }

  Future<void> _loadCampaignDetails() async {
    final prefs = await SharedPreferences.getInstance();
    widget.campaignId = prefs.getInt("campaignId")!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    
    campaignsProvider.fetchCampaignDetails(
      campaignId: widget.campaignId,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );
  }

  void _showAddMaterialModal() {
    showDialog(
      context: context,
      builder: (context) => AddMaterialModal(campaignId: widget.campaignId),
    ).then((result) {
      if (result == true) {
        _loadCampaignDetails();
      }
    });
  }

  void _showAddEventModal() {
    showDialog(
      context: context,
      builder: (context) => AddEventModal(campaignId: widget.campaignId),
    ).then((result) {
      if (result == true) {
        _loadCampaignDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dettagli Campagna'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const HorizontalMenu(currentRoute: '/campaigns'),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
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
                          const SizedBox(height: 8),
                          Text(
                            campaignsProvider.error!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCampaignDetails,
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    );
                  }

                  final campaign = campaignsProvider.selectedCampaign;
                  if (campaign == null) {
                    return const Center(
                      child: Text('Campagna non trovata'),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header della campagna
                        _buildCampaignHeader(campaign),
                        
                        const SizedBox(height: 32),
                        
                        // Statistiche
                        _buildStatsSection(campaign),
                        
                        const SizedBox(height: 32),
                        
                        // Sezioni Materiali ed Eventi
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MaterialSection(
                                materials: campaign.materials ?? [],
                                onAddMaterial: _showAddMaterialModal,
                                campaignId: widget.campaignId,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: EventSection(
                                events: campaign.events ?? [],
                                onAddEvent: _showAddEventModal,
                                campaignId: widget.campaignId,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Timeline
                        TimelineSection(
                          materials: campaign.materials ?? [],
                          events: campaign.events ?? [],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Candidati
                        CandidatesSection(
                          candidates: campaign.candidates ?? [],
                          campaignId: widget.campaignId,
                          onCandidatesChanged: _loadCampaignDetails,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHeader(campaign) {
    final isActive = campaign.status == 'activate';
    final statusColor = isActive ? AppTheme.successGreen : AppTheme.warningYellow;
    final statusText = isActive ? 'Attiva' : 'Bozza';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Campaign campaign) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Materiali',
            campaign.materials!.length.toString(),
            Icons.description,
            AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Eventi',
            campaign.events!.length.toString(),
            Icons.event,
            AppTheme.warningYellow,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Candidati',
            campaign.candidates!.length.toString(),
            Icons.people,
            AppTheme.errorRed,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textMedium, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
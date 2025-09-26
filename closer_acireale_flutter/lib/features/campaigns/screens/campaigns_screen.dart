import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_modal.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'single_campaign_screen.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCampaigns();
    });
  }

  void _loadCampaigns() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    
    campaignsProvider.fetchCampaigns(
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );
  }

  void _showCreateCampaignModal() {
    showDialog(
      context: context,
      builder: (context) => const CampaignModal(),
    ).then((result) {
      if (result == true) {
        _loadCampaigns();
      }
    });
  }

  void _showEditCampaignModal(campaign) {
    showDialog(
      context: context,
      builder: (context) => CampaignModal(campaign: campaign),
    ).then((result) {
      if (result == true) {
        _loadCampaigns();
      }
    });
  }

  void _showDeleteDialog(campaign) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Conferma Eliminazione',
        content: 'Sei sicuro di voler eliminare la campagna "${campaign.title}"? Questa azione è irreversibile.',
        onConfirm: () => _deleteCampaign(campaign.id),
      ),
    );
  }

  Future<void> _deleteCampaign(int campaignId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);
    
    final success = await campaignsProvider.deleteCampaign(
      campaignId: campaignId,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Campagna eliminata con successo' 
            : 'Errore durante l\'eliminazione'
          ),
          backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _navigateToSingleCampaign(campaign) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("campaignId", campaign.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleCampaignScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Campagne'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con titolo e bottone aggiungi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gestione Campagne',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateCampaignModal,
                        icon: const Icon(Icons.add),
                        label: const Text('Aggiungi Campagna'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 12
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Lista campagne
                  Expanded(
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
                                  onPressed: _loadCampaigns,
                                  child: const Text('Riprova'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (campaignsProvider.campaigns.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: 64,
                                  color: AppTheme.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nessuna campagna trovata',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Inizia creando la tua prima campagna',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showCreateCampaignModal,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crea Prima Campagna'),
                                ),
                              ],
                            ),
                          );
                        }

                        // Grid di campagne
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Calcola il numero di colonne in base alla larghezza
                            int crossAxisCount = 1;
                            if (constraints.maxWidth > 1200) {
                              crossAxisCount = 3;
                            } else if (constraints.maxWidth > 768) {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: campaignsProvider.campaigns.length,
                              itemBuilder: (context, index) {
                                final campaign = campaignsProvider.campaigns[index];
                                return CampaignCard(
                                  campaign: campaign,
                                  onTap: () => _navigateToSingleCampaign(campaign),
                                  onEdit: () => _showEditCampaignModal(campaign),
                                  onDelete: () => _showDeleteDialog(campaign),
                                );
                              },
                            );
                          },
                        );
                      },
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
}
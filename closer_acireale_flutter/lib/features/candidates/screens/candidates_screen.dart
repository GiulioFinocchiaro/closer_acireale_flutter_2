import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/models/candidate_model.dart';
import '../../../core/providers/candidates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/candidate_card.dart';
import '../widgets/candidate_form_modal.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CandidatesProvider>(context, listen: false);
      provider.initialize().then((_) => provider.getCandidates());
    });
  }

  void _showAddCandidateModal() {
    // Carica prima gli utenti idonei
    final provider = Provider.of<CandidatesProvider>(context, listen: false);
    provider.getEligibleUsers().then((_) {
      showDialog(
        context: context,
        builder: (context) => CandidateFormModal(
          title: 'Aggiungi Nuovo Candidato',
          onSave: _handleAddCandidate,
        ),
      );
    });
  }

  void _showEditCandidateModal(Candidate candidate) {
    showDialog(
      context: context,
      builder: (context) => CandidateFormModal(
        title: 'Modifica Candidato',
        candidate: candidate,
        onSave: (userId, classYear, description, photo, manifesto) => 
          _handleEditCandidate(candidate.id, classYear, description, photo, manifesto),
      ),
    );
  }

  Future<void> _handleAddCandidate(int userId, String classYear, String description, String? photo, String? manifesto) async {
    final provider = Provider.of<CandidatesProvider>(context, listen: false);
    
    final success = await provider.addCandidate(
      userId: userId,
      classYear: classYear,
      description: description,
      photo: photo,
      manifesto: manifesto,
    );

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Candidato aggiunto con successo!');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante l\'aggiunta del candidato');
    }
  }

  Future<void> _handleEditCandidate(int id, String classYear, String description, String? photo, String? manifesto) async {
    final provider = Provider.of<CandidatesProvider>(context, listen: false);
    
    final success = await provider.updateCandidate(
      id: id,
      classYear: classYear,
      description: description,
      photo: photo,
      manifesto: manifesto,
    );

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Candidato modificato con successo!');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante la modifica del candidato');
    }
  }

  void _showDeleteDialog(Candidate candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare il candidato "${candidate.userName}"? Questa azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => _handleDeleteCandidate(candidate.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteCandidate(int id) async {
    Navigator.of(context).pop(); // Chiudi dialog
    
    final provider = Provider.of<CandidatesProvider>(context, listen: false);
    final success = await provider.deleteCandidate(id);
    
    if (success) {
      _showSuccessSnackBar('Candidato eliminato con successo!');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante l\'eliminazione');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestione Candidati'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const HorizontalMenu(currentRoute: '/candidates'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gestione Candidati',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        CustomButton(
                          text: 'Aggiungi Candidato',
                          icon: Icons.add,
                          onPressed: _showAddCandidateModal,
                        ),
                      ],
                    ),
                    Container(
                      height: 2.h,
                      margin: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                    Expanded(
                      child: Consumer<CandidatesProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Caricamento candidati...'),
                                ],
                              ),
                            );
                          }

                          if (provider.errorMessage != null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48.w,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    provider.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  CustomButton(
                                    text: 'Riprova',
                                    onPressed: provider.getCandidates,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (provider.candidates.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.how_to_vote,
                                    size: 64.w,
                                    color: AppTheme.textMedium,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Nessun candidato trovato',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Aggiungine uno per iniziare!',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: provider.candidates.length,
                            itemBuilder: (context, index) {
                              final candidate = provider.candidates[index];
                              return CandidateCard(
                                candidate: candidate,
                                onEdit: () => _showEditCandidateModal(candidate),
                                onDelete: () => _showDeleteDialog(candidate),
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
          ),
        ],
      ),
    );
  }
}
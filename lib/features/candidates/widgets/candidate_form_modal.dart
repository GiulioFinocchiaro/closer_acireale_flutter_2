import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/models/candidate_model.dart';
import '../../../core/providers/candidates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';

class CandidateFormModal extends StatefulWidget {
  final String title;
  final Candidate? candidate;
  final Function(int userId, String classYear, String description, String? photo, String? manifesto) onSave;

  const CandidateFormModal({
    super.key,
    required this.title,
    this.candidate,
    required this.onSave,
  });

  @override
  State<CandidateFormModal> createState() => _CandidateFormModalState();
}

class _CandidateFormModalState extends State<CandidateFormModal> {
  final _classYearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoController = TextEditingController();
  final _manifestoController = TextEditingController();
  
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.candidate != null) {
      _classYearController.text = widget.candidate!.classYear ?? '';
      _descriptionController.text = widget.candidate!.description ?? '';
      _photoController.text = widget.candidate!.photo ?? '';
      _manifestoController.text = widget.candidate!.manifesto ?? '';
    }
  }

  void _handleSubmit() {
    if (widget.candidate == null && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona un utente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_classYearController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compila tutti i campi obbligatori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Per le modifiche, usiamo un ID fittizio (-1) dato che l'API probabilmente usa l'ID del candidato
    final userId = _selectedUserId ?? -1;

    widget.onSave(
      userId,
      _classYearController.text,
      _descriptionController.text,
      _photoController.text.isNotEmpty ? _photoController.text : null,
      _manifestoController.text.isNotEmpty ? _manifestoController.text : null,
    );
  }

  @override
  void dispose() {
    _classYearController.dispose();
    _descriptionController.dispose();
    _photoController.dispose();
    _manifestoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(24.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500.w,
          maxHeight: 600.h,
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 24.w,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Dropdown utenti (solo per nuovi candidati)
                      if (widget.candidate == null) ...[
                        Consumer<CandidatesProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoadingUsers) {
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Caricamento utenti...'),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seleziona Utente',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.borderLight),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedUserId,
                                      hint: const Text('Seleziona un utente...'),
                                      isExpanded: true,
                                      items: provider.eligibleUsers.map((user) {
                                        return DropdownMenuItem<int>(
                                          value: user.id,
                                          child: Text('${user.name} (${user.email})'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedUserId = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                if (provider.eligibleUsers.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      'Nessun utente idoneo trovato',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],
                      
                      // Anno classe
                      CustomTextField(
                        label: 'Anno Classe',
                        controller: _classYearController,
                        hint: 'Es: 3A, 4B',
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Descrizione
                      CustomTextField(
                        label: 'Descrizione',
                        controller: _descriptionController,
                        hint: 'Breve descrizione del candidato',
                        maxLines: 4,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // URL Foto
                      CustomTextField(
                        label: 'URL Foto (Opzionale)',
                        controller: _photoController,
                        hint: 'URL della foto del candidato',
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // URL Manifesto
                      CustomTextField(
                        label: 'URL Manifesto (Opzionale)',
                        controller: _manifestoController,
                        hint: 'URL del manifesto elettorale',
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Bottoni
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  SizedBox(width: 8.w),
                  Consumer<CandidatesProvider>(
                    builder: (context, provider, child) {
                      final canSave = widget.candidate != null || 
                          (provider.eligibleUsers.isNotEmpty && !provider.isLoadingUsers);
                      
                      return ElevatedButton(
                        onPressed: canSave ? _handleSubmit : null,
                        child: Text(
                          widget.candidate != null ? 'Salva Modifiche' : 'Aggiungi Candidato',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/campaign_model.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';

class CampaignModal extends StatefulWidget {
  final Campaign? campaign;

  const CampaignModal({
    super.key,
    this.campaign,
  });

  @override
  State<CampaignModal> createState() => _CampaignModalState();
}

class _CampaignModalState extends State<CampaignModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'draft';
  bool _isLoading = false;

  bool get _isEditing => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.campaign!.title;
      _descriptionController.text = widget.campaign!.description;
      _status = widget.campaign!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);

    bool success;
    if (_isEditing) {
      success = await campaignsProvider.updateCampaign(
        campaignId: widget.campaign!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        schoolId: schoolsProvider.schoolSelected.id,
        token: authProvider.token,
      );
    } else {
      success = await campaignsProvider.createCampaign(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        schoolId: schoolsProvider.schoolSelected.id,
        token: authProvider.token,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
              ? 'Campagna aggiornata con successo' 
              : 'Campagna creata con successo'
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(campaignsProvider.error ?? 'Errore durante l\'operazione'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : null,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _isEditing ? 'Modifica Campagna' : 'Crea Nuova Campagna',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo
                  Text(
                    'Titolo della Campagna',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Inserisci il titolo della campagna',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Il titolo è obbligatorio';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Descrizione
                  Text(
                    'Descrizione della Campagna',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Inserisci una descrizione per la campagna',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descrizione è obbligatoria';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stato
                  Text(
                    'Stato',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      hintText: 'Seleziona lo stato',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'draft',
                        child: Text('Bozza'),
                      ),
                      DropdownMenuItem(
                        value: 'activate',
                        child: Text('Attiva'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleziona uno stato';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bottoni
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annulla'),
                ),
                
                const SizedBox(width: 16),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCampaign,
                  child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Salva Modifiche' : 'Crea Campagna'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
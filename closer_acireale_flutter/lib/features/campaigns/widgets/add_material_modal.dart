import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/graphic_asset_model.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';
import 'asset_selector_dialog.dart';

class AddMaterialModal extends StatefulWidget {
  final int campaignId;

  const AddMaterialModal({
    super.key,
    required this.campaignId,
  });

  @override
  State<AddMaterialModal> createState() => _AddMaterialModalState();
}

class _AddMaterialModalState extends State<AddMaterialModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  GraphicAsset? _selectedAsset;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectAsset() async {
    final result = await showDialog<GraphicAsset>(
      context: context,
      builder: (context) => const AssetSelectorDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedAsset = result;
      });
    }
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      _dateController.text = selectedDate.toIso8601String().split('T')[0];
    }
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate() || _selectedAsset == null) {
      if (_selectedAsset == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seleziona un asset grafico'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);

    final success = await campaignsProvider.addMaterial(
      campaignId: widget.campaignId,
      materialName: _nameController.text.trim(),
      publishedAt: _dateController.text,
      graphicId: _selectedAsset!.id,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materiale creato con successo'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(campaignsProvider.error ?? 'Errore durante la creazione'),
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
              'Aggiungi Materiale',
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
                  // Nome
                  Text(
                    'Nome',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nome del materiale',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Il nome è obbligatorio';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Data
                  Text(
                    'Data di Pubblicazione',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Seleziona la data',
                      suffixIcon: IconButton(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La data è obbligatoria';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Asset selector
                  Text(
                    'Scegli l\'asset',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedAsset?.fileName ?? 'Nessun asset selezionato',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _selectedAsset != null 
                                ? AppTheme.textDark 
                                : AppTheme.textMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _selectAsset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.textMedium,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Seleziona Asset'),
                        ),
                      ],
                    ),
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
                  onPressed: _isLoading ? null : _saveMaterial,
                  child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aggiungi Materiale'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
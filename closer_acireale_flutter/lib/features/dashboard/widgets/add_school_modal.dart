import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class AddSchoolModal extends StatefulWidget {
  const AddSchoolModal({super.key});

  @override
  State<AddSchoolModal> createState() => _AddSchoolModalState();
}

class _AddSchoolModalState extends State<AddSchoolModal> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
      
      // Qui dovresti implementare il metodo addSchool nel provider
      // Per ora simulo il salvataggio
      await Future.delayed(const Duration(seconds: 1));
      
      if (context.mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scuola aggiunta con successo!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'aggiunta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aggiungi Nuova Scuola',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Form fields
              CustomTextField(
                controller: _schoolNameController,
                label: 'Nome Scuola',
                hint: 'Inserisci il nome della scuola',
                prefixIcon: Icons.school,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Il nome della scuola è obbligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'Il nome deve essere di almeno 3 caratteri';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _addressController,
                label: 'Indirizzo',
                hint: 'Inserisci l\'indirizzo della scuola',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'indirizzo è obbligatorio';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Inserisci l\'email della scuola',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'email è obbligatoria';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Inserisci un\'email valida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Telefono',
                hint: 'Inserisci il numero di telefono',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                      return 'Inserisci un numero di telefono valido';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Azioni
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    text: 'Aggiungi Scuola',
                    onPressed: _isLoading ? null : _handleSave,
                    icon: _isLoading ? null : Icons.add,
                    isLoading: _isLoading,
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
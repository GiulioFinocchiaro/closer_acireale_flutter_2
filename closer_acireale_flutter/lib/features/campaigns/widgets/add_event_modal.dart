import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/campaigns_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/schools_provider.dart';

class AddEventModal extends StatefulWidget {
  final int campaignId;

  const AddEventModal({
    super.key,
    required this.campaignId,
  });

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      _timeController.text = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _buildEventDateTime() {
    if (_dateController.text.isEmpty) return '';
    
    final time = _timeController.text.isNotEmpty ? _timeController.text : '00:00';
    return '${_dateController.text} $time:00';
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: false);

    final success = await campaignsProvider.addEvent(
      campaignId: widget.campaignId,
      eventName: _nameController.text.trim(),
      eventDescription: _descriptionController.text.trim(),
      eventDate: _buildEventDateTime(),
      location: _locationController.text.trim().isNotEmpty 
        ? _locationController.text.trim() 
        : null,
      schoolId: schoolsProvider.schoolSelected.id,
      token: authProvider.token,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento creato con successo'),
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
              'Aggiungi Evento',
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
                      hintText: 'Nome dell\'evento',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Il nome è obbligatorio';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Descrizione
                  Text(
                    'Descrizione',
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
                      hintText: 'Descrizione dell\'evento',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descrizione è obbligatoria';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Luogo
                  Text(
                    'Luogo',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Luogo dell\'evento (opzionale)',
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Data
                  Text(
                    'Data',
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
                  
                  // Ora
                  Text(
                    'Scegli l\'ora',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Seleziona l\'ora (opzionale)',
                      suffixIcon: IconButton(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                      ),
                    ),
                    onTap: _selectTime,
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
                  onPressed: _isLoading ? null : _saveEvent,
                  child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aggiungi Evento'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
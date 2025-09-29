import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../core/models/candidate_model.dart';
import '../../../core/models/graphic_asset_model.dart';
import '../../../core/providers/candidates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'candidate_asset_selector.dart';

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

  int? _selectedUserId;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  GraphicAsset? _selectedAsset;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.candidate != null) {
      _classYearController.text = widget.candidate!.classYear ?? '';
      _descriptionController.text = widget.candidate!.description ?? '';
      // Per le modifiche, non inizializziamo l'immagine poiché useremo solo il selettore
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

    // Convertiamo l'immagine in base64 se selezionata o usiamo l'URL dell'asset
    String? photoBase64;
    if (_selectedImageBytes != null && _selectedImageName != null) {
      // Uso immagine caricata manualmente
      final base64String = base64Encode(_selectedImageBytes!);
      // Determiniamo il MIME type dall'estensione del file
      String mimeType = 'image/jpeg'; // default
      final extension = _selectedImageName!.split('.').last.toLowerCase();
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }
      photoBase64 = 'data:$mimeType;base64,$base64String';
    } else if (_selectedAsset != null) {
      // Uso grafica selezionata - inviamo l'URL completo
      photoBase64 = _selectedAsset!.fullUrl;
    }

    widget.onSave(
      userId,
      _classYearController.text,
      _descriptionController.text,
      photoBase64,
      null, // Non usiamo più il manifesto
    );
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.first;
        setState(() {
          _selectedImageBytes = file.bytes!;
          _selectedImageName = file.name;
          _selectedAsset = null; // Reset selected asset if user picks new file
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore selezione immagine: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella selezione dell\'immagine: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectFromGraphics() async {
    try {
      final GraphicAsset? selectedAsset = await showDialog<GraphicAsset>(
        context: context,
        builder: (context) => const CandidateAssetSelector(),
      );

      if (selectedAsset != null) {
        setState(() {
          _selectedAsset = selectedAsset;
          _selectedImageBytes = null; // Reset manual upload if asset selected
          _selectedImageName = null;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore selezione asset: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella selezione della grafica: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedAsset = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      // Mostra l'immagine caricata manualmente
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.memory(
              _selectedImageBytes!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _clearSelection,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.w,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_selectedAsset != null) {
      // Mostra la grafica selezionata
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              _selectedAsset!.fullUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 32.w,
                        color: AppTheme.textMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Errore caricamento',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _clearSelection,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.w,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Mostra il placeholder
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48.w,
            color: AppTheme.textMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Seleziona una foto',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textMedium,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Dalle grafiche o carica un file',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _classYearController.dispose();
    _descriptionController.dispose();
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

                      // Selezione Immagine con più opzioni
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto Candidato (Opzionale)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Bottoni per scegliere il metodo di selezione
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectFromGraphics,
                                  icon: Icon(Icons.photo_library, size: 16.w),
                                  label: Text(
                                    'Dalle Grafiche',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
                                    side: BorderSide(color: AppTheme.primaryBlue),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: Icon(Icons.upload_file, size: 16.w),
                                  label: Text(
                                    'Carica File',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
                                    side: BorderSide(color: AppTheme.primaryBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Area di anteprima
                          Container(
                            width: double.infinity,
                            height: 120.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.borderLight,
                                style: BorderStyle.solid,
                                width: 2.w,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              color: Colors.grey[50],
                            ),
                            child: _buildImagePreview(),
                          ),

                          // Info sul file selezionato
                          if (_selectedImageName != null) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.file_present, size: 16.w, color: AppTheme.primaryBlue),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'File caricato: $_selectedImageName',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (_selectedAsset != null) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.photo_library, size: 16.w, color: AppTheme.primaryBlue),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Grafica selezionata: ${_selectedAsset!.description.isNotEmpty ? _selectedAsset!.description : _selectedAsset!.fileName}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
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
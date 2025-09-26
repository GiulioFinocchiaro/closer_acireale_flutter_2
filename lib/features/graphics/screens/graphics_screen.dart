import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/models/graphic_asset_model.dart';
import '../../../core/providers/graphics_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_modal.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/graphic_card.dart';
import '../widgets/graphic_preview_dialog.dart';
import '../widgets/upload_area.dart';

class GraphicsScreen extends StatefulWidget {
  const GraphicsScreen({super.key});

  @override
  State<GraphicsScreen> createState() => _GraphicsScreenState();
}

class _GraphicsScreenState extends State<GraphicsScreen> {
  final _assetTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  GraphicAsset? _editingGraphic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GraphicsProvider>(context, listen: false);
      provider.initialize().then((_) => provider.getGraphics());
    });
  }

  @override
  void dispose() {
    _assetTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddGraphicModal() {
    _resetForm();
    _showGraphicModal(isEdit: false);
  }

  void _showEditGraphicModal(GraphicAsset graphic) {
    _editingGraphic = graphic;
    _assetTypeController.text = graphic.asset_type;
    _descriptionController.text = graphic.description;
    _selectedFileBytes = null;
    _selectedFileName = null;
    _showGraphicModal(isEdit: true);
  }

  void _resetForm() {
    _editingGraphic = null;
    _assetTypeController.clear();
    _descriptionController.clear();
    _selectedFileBytes = null;
    _selectedFileName = null;
  }

  void _showGraphicModal({required bool isEdit}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => CustomModal(
          title: isEdit ? 'Modifica Grafica' : 'Aggiungi Grafica',
          confirmText: isEdit ? 'Salva Modifiche' : 'Aggiungi Grafica',
          cancelText: 'Annulla',
          fields: [
            if (!isEdit) ...[
              const Text(
                'Seleziona File',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              UploadArea(
                selectedFileName: _selectedFileName,
                onFilePicked: (bytes, fileName) {
                  setModalState(() {
                    _selectedFileBytes = bytes;
                    _selectedFileName = fileName;
                  });
                },
              ),
              SizedBox(height: 16.h),
            ],
            CustomTextField(
              label: 'Tipo di Asset',
              controller: _assetTypeController,
              hint: 'Es: Logo, Banner, Icona',
            ),
            CustomTextField(
              label: 'Descrizione',
              controller: _descriptionController,
              hint: 'Breve descrizione...',
              maxLines: 4,
            ),
          ],
          onConfirm: () => _handleSaveGraphic(isEdit),
        ),
      ),
    );
  }

  Future<void> _handleSaveGraphic(bool isEdit) async {
    final provider = Provider.of<GraphicsProvider>(context, listen: false);
    
    if (_assetTypeController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showErrorSnackBar('Compila tutti i campi obbligatori');
      return;
    }

    if (!isEdit && (_selectedFileBytes == null || _selectedFileName == null)) {
      _showErrorSnackBar('Seleziona un file');
      return;
    }

    bool success = false;
    
    if (isEdit && _editingGraphic != null) {
      success = await provider.updateGraphic(
        id: _editingGraphic!.id,
        assetType: _assetTypeController.text,
        description: _descriptionController.text,
      );
    } else {
      success = await provider.uploadGraphic(
        fileBytes: _selectedFileBytes!,
        fileName: _selectedFileName!,
        assetType: _assetTypeController.text,
        description: _descriptionController.text,
      );
    }

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar(isEdit ? 'Grafica modificata con successo' : 'Grafica caricata con successo');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante l\'operazione');
    }
  }

  void _showDeleteDialog(GraphicAsset graphic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare la grafica "${graphic.fileName}"? Questa azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => _handleDeleteGraphic(graphic.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteGraphic(int id) async {
    Navigator.of(context).pop(); // Chiudi dialog
    
    final provider = Provider.of<GraphicsProvider>(context, listen: false);
    final success = await provider.deleteGraphic(id);
    
    if (success) {
      _showSuccessSnackBar('Grafica eliminata con successo');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante l\'eliminazione');
    }
  }

  void _showPreview(GraphicAsset graphic) {
    showDialog(
      context: context,
      builder: (context) => GraphicPreviewDialog(graphic: graphic),
    );
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
      appBar: const CustomAppBar(title: 'Gestione Grafiche'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const HorizontalMenu(currentRoute: '/graphics'),
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
                          'Gestione Grafiche',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        CustomButton(
                          text: 'Aggiungi Grafica',
                          icon: Icons.add,
                          onPressed: _showAddGraphicModal,
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
                      child: Consumer<GraphicsProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
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
                                    onPressed: provider.getGraphics,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (provider.graphics.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 64.w,
                                    color: AppTheme.textMedium,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Nessuna grafica trovata',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Carica la tua prima grafica!',
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
                              childAspectRatio: 0.85,
                            ),
                            itemCount: provider.graphics.length,
                            itemBuilder: (context, index) {
                              final graphic = provider.graphics[index];
                              return GraphicCard(
                                graphic: graphic,
                                onPreview: () => _showPreview(graphic),
                                onEdit: () => _showEditGraphicModal(graphic),
                                onDelete: () => _showDeleteDialog(graphic),
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
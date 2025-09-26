import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/models/role_model.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RoleFormModal extends StatefulWidget {
  final String title;
  final RoleModel? role;
  final Function(String name, int level, String color, List<String> permissions) onSave;

  const RoleFormModal({
    super.key,
    required this.title,
    this.role,
    required this.onSave,
  });

  @override
  State<RoleFormModal> createState() => _RoleFormModalState();
}

class _RoleFormModalState extends State<RoleFormModal> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  
  Color _selectedColor = Colors.black;
  final List<String> _selectedPermissions = [];
  List<String> _availablePermissions = [];
  bool _isLoadingPermissions = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadAvailablePermissions();
  }

  void _initializeForm() {
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _levelController.text = widget.role!.level.toString();
      _selectedColor = _getColorFromString(widget.role!.color);
      _selectedPermissions.addAll(
        widget.role!.permissions.map((p) => p.name).toList(),
      );
    } else {
      _levelController.text = '1';
    }
  }

  Future<void> _loadAvailablePermissions() async {
    setState(() {
      _isLoadingPermissions = true;
    });

    try {
      final provider = Provider.of<RoleProvider>(context, listen: false);
      await provider.getAvailablePermissions();
      
      setState(() {
        _availablePermissions = provider.availablePermissions;
        _isLoadingPermissions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPermissions = false;
      });
      // Fallback permissions list
      _availablePermissions = [
        'users.view_all',
        'users.create',
        'users.update_all',
        'users.delete_all',
        'roles.view_all',
        'roles.create',
        'roles.update',
        'roles.delete',
        'candidates.view_all',
        'candidates.create',
        'candidates.update_all',
        'candidates.delete_all',
        'media.view_all',
        'media.upload',
        'media.update_all',
        'media.delete_all',
      ];
    }
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty || _levelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compila tutti i campi obbligatori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un permesso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final level = int.tryParse(_levelController.text);
    if (level == null || level < 1 || level > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il livello deve essere un numero tra 1 e 100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSave(
      _nameController.text,
      level,
      _colorToHex(_selectedColor),
      _selectedPermissions,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
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
                      // Nome e livello
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Nome Ruolo',
                              controller: _nameController,
                              hint: 'Es: Amministratore',
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CustomTextField(
                              label: 'Livello Privilegio (1-100)',
                              controller: _levelController,
                              hint: '1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Colore ruolo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Colore Ruolo',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showColorPicker,
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                _colorToHex(_selectedColor),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Permessi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permessi',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            height: 200.h,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: _isLoadingPermissions
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 8),
                                        Text('Caricamento permessi...'),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _availablePermissions.length,
                                    itemBuilder: (context, index) {
                                      final permission = _availablePermissions[index];
                                      final isSelected = _selectedPermissions.contains(permission);
                                      
                                      return CheckboxListTile(
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedPermissions.add(permission);
                                            } else {
                                              _selectedPermissions.remove(permission);
                                            }
                                          });
                                        },
                                        title: Text(
                                          permission,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        dense: true,
                                        controlAffinity: ListTileControlAffinity.leading,
                                      );
                                    },
                                  ),
                          ),
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
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Salva'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Colore'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
      return Colors.black;
    } catch (e) {
      return Colors.black;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

// Simple color picker widget
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return Wrap(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 32.w,
            height: 32.w,
            margin: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: pickerColor == color ? Colors.white : Colors.transparent,
                width: 2.w,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
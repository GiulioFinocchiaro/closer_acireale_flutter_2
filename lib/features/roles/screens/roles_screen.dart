import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/models/role_model.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_modal.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/role_card.dart';
import '../widgets/role_form_modal.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RoleProvider>(context, listen: false);
      provider.initialize().then((_) => provider.getRoles());
    });
  }

  void _showAddRoleModal() {
    showDialog(
      context: context,
      builder: (context) => RoleFormModal(
        title: 'Aggiungi Nuovo Ruolo',
        onSave: _handleAddRole,
      ),
    );
  }

  void _showEditRoleModal(RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => RoleFormModal(
        title: 'Modifica Ruolo',
        role: role,
        onSave: (name, level, color, permissions) => _handleEditRole(role.id, name, level, color, permissions),
      ),
    );
  }

  Future<void> _handleAddRole(String name, int level, String color, List<String> permissions) async {
    final provider = Provider.of<RoleProvider>(context, listen: false);
    
    final success = await provider.addRole(
      name: name,
      privilegeLevel: level,
      color: color,
      permissions: permissions,
    );

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Ruolo aggiunto con successo!');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante l\'aggiunta del ruolo');
    }
  }

  Future<void> _handleEditRole(int id, String name, int level, String color, List<String> permissions) async {
    final provider = Provider.of<RoleProvider>(context, listen: false);
    
    final success = await provider.updateRole(
      id: id,
      name: name,
      privilegeLevel: level,
      color: color,
      permissions: permissions,
    );

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Ruolo modificato con successo!');
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'Errore durante la modifica del ruolo');
    }
  }

  void _showDeleteDialog(RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare il ruolo "${role.name}"? Questa azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => _handleDeleteRole(role.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteRole(int id) async {
    Navigator.of(context).pop(); // Chiudi dialog
    
    final provider = Provider.of<RoleProvider>(context, listen: false);
    final success = await provider.deleteRole(id);
    
    if (success) {
      _showSuccessSnackBar('Ruolo eliminato con successo!');
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
      appBar: const CustomAppBar(title: 'Gestione Ruoli'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const HorizontalMenu(currentRoute: '/roles'),
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
                          'Gestione Ruoli',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        CustomButton(
                          text: 'Aggiungi Ruolo',
                          icon: Icons.add,
                          onPressed: _showAddRoleModal,
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
                      child: Consumer<RoleProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Caricamento ruoli...'),
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
                                    onPressed: provider.getRoles,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (provider.roles.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 64.w,
                                    color: AppTheme.textMedium,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Nessun ruolo presente',
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
                              childAspectRatio: 0.85,
                            ),
                            itemCount: provider.roles.length,
                            itemBuilder: (context, index) {
                              final role = provider.roles[index];
                              return RoleCard(
                                role: role,
                                onEdit: () => _showEditRoleModal(role),
                                onDelete: () => _showDeleteDialog(role),
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
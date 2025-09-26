import 'package:closer_acireale_flutter/core/models/role_model.dart';
import 'package:closer_acireale_flutter/core/providers/role_provider.dart';
import 'package:closer_acireale_flutter/core/providers/schools_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_modal.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/user_card.dart';
import '../widgets/user_modal.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.token != null) {
      await userProvider.loadUsers(context);
    }
  }

  void _showDeleteConfirmation(int? userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Text('Conferma Eliminazione'),
          content: Text('Sei sicuro di voler eliminare l\'utente "$userName"? Questa azione è irreversibile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => _deleteUser(userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int? userId) async {
    Navigator.of(context).pop(); // Chiudi il dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.token != null) {
      final success = await userProvider.deleteUser(userId);

      userProvider.loadUsers(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Utente eliminato con successo' : 'Errore nell\'eliminazione'),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestione Utenti'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          // Menu orizzontale
          const HorizontalMenu(currentRoute: '/users'),

          // Contenuto principale
          Expanded(
            child: Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header della sezione
                    _buildHeader(),

                    // Search bar e pulsante aggiungi
                    _buildTopControls(),

                    // Lista utenti
                    Expanded(child: _buildUsersList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            size: 28.w,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(width: 12.w),
          Text(
            'Gestione Utenti',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: ResponsiveUtils.isMobile(context)
          ? Column(
        children: [
          _buildSearchField(),
          SizedBox(height: 16.h),
          _buildAddUserButton(),
        ],
      )
          : Row(
        children: [
          Expanded(child: _buildSearchField()),
          SizedBox(width: 16.w),
          _buildAddUserButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cerca utenti per nome o email...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppTheme.backgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildAddUserButton() {
    return CustomButton(
      text: 'Registra Utente',
      icon: Icons.add,
      onPressed: () => _showEditAddUser(context),
      width: ResponsiveUtils.isMobile(context) ? double.infinity : null,
    );
  }

  Widget _buildUsersList() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.w,
                  color: AppTheme.errorRed,
                ),
                SizedBox(height: 16.h),
                Text(
                  userProvider.errorMessage!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.errorRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: 'Riprova',
                  onPressed: _loadUsers,
                ),
              ],
            ),
          );
        }

        final users = _searchQuery.isEmpty
            ? userProvider.users
            : userProvider.searchUsers(_searchQuery);

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64.w,
                  color: AppTheme.textLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  _searchQuery.isEmpty
                      ? 'Nessun utente trovato'
                      : 'Nessun utente corrisponde alla ricerca',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadUsers,
          child: ResponsiveUtils.isMobile(context)
              ? _buildMobileUsersList(users)
              : _buildDesktopUsersGrid(users),
        );
      },
    );
  }

  Widget _buildMobileUsersList(List<UserModel> users) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: UserCard(
            user: users[index],
            onEdit: () {
              _showEditAddUser(context, users[index]);
            },
            onDelete: () => _showDeleteConfirmation(
              users[index].id,
              users[index].name,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopUsersGrid(List<UserModel> users) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
          context,
          tabletColumns: 2,
          desktopColumns: 3,
        ),
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserCard(
          user: users[index],
          onEdit: () {
            _showEditAddUser(context, users[index]);
          },
          onDelete: () => _showDeleteConfirmation(
            users[index].id,
            users[index].name,
          ),
        );
      },
    );
  }

  Future<void> _showEditAddUser(BuildContext context, [UserModel? user]) async {
    final TextEditingController nameController =
    TextEditingController(text: user?.name ?? '');
    final TextEditingController emailController =
    TextEditingController(text: user?.email ?? '');

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    await roleProvider.getRoles();

    // Copia dei ruoli già assegnati (se siamo in edit)
    final List<RoleModel> selectedRoles =
    user != null ? List<RoleModel>.from(user.roles) : <RoleModel>[];

    await showDialog(
      context: context,
      builder: (context) {
        bool resetPassword = false; // variabile locale del dialog

        return CustomModal(
          title: user != null
              ? 'Modifica utente: ${user.name}'
              : 'Registra utente',
          fields: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome utente'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail utente'),
            ),
            const SizedBox(height: 12),

            // ✅ Checkbox Reimposta Password con StatefulBuilder
            StatefulBuilder(
              builder: (context, setStateSB) {
                return CheckboxListTile(
                  title: const Text('Reimposta password'),
                  value: resetPassword,
                  onChanged: (bool? value) {
                    setStateSB(() {
                      resetPassword = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.errorRed,
                );
              },
            ),

            const SizedBox(height: 12),
            Text(
              'Ruoli',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8.h),

            // ✅ Checkbox per ruoli con StatefulBuilder
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: StatefulBuilder(
                builder: (context, setStateSB) {
                  final roles = roleProvider.roles;
                  if (roles.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        'Nessun ruolo disponibile',
                        style: TextStyle(
                            fontSize: 14.sp, color: AppTheme.textMedium),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      ...roles.map((role) {
                        return CheckboxListTile(
                          title: Text(
                            role.name,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          value: selectedRoles.contains(role),
                          onChanged: (bool? value) {
                            setStateSB(() {
                              if (value ?? false) {
                                if (!selectedRoles.contains(role)) {
                                  selectedRoles.add(role);
                                }
                              } else {
                                selectedRoles
                                    .removeWhere((r) => r.id == role.id);
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryBlue,
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
          confirmText: user != null ? 'Modifica Utente' : 'Registra Utente',
          onConfirm: () async {
            final name = nameController.text.trim();
            final email = emailController.text.trim();

            if (name.isEmpty || email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('I parametri non possono essere vuoti')),
              );
              return;
            }

            final userProvider =
            Provider.of<UserProvider>(context, listen: false);

            final schoolId =
                context.read<SchoolsProvider>().schoolSelected.id;

            if (user == null) {
              await userProvider.addUser(
                  name: name,
                  email: email,
                  roles: selectedRoles,
                  schoolId: schoolId,
                  token: Provider.of<AuthProvider>(context, listen: false).token
              );
              userProvider.loadUsers(context);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Utente "$name" registrato con successo')),
              );
            } else {
              try {
                await userProvider.updateUser(
                  user.id,
                  name,
                  email,
                  resetPassword,
                  selectedRoles,
                  schoolId,
                  token: Provider.of<AuthProvider>(context, listen: false).token
                );

                userProvider.loadUsers(context);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Utente "${user.name}" modificato')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore nella modifica dell\'utente')),
                );
              }
            }
          },
          cancelText: 'Annulla',
        );
      },
    );

    // Dispose dei controller dopo che il dialog è stato chiuso
    nameController.dispose();
    emailController.dispose();
  }
}
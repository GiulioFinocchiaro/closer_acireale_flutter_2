import 'package:closer_acireale_flutter/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogout = true,
  });

  @override
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.blueIndigoGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveUtils.isMobile(context)
            ? _buildMobileTitle(context)
            : _buildDesktopHeader(context),
        actions: _buildActions(context),
        toolbarHeight: preferredSize.height,
      ),
    );
  }

  Widget _buildMobileTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        // Logo e titolo principale
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Icon(
            Icons.bar_chart,
            size: 24.w,
            color: Colors.white70,
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Closer Acireale',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (ResponsiveUtils.isDesktop(context))
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.currentUser?.isAdmin ?? false) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Color(int.parse(authProvider.currentUser!.roles.first.color.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 12.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            authProvider.currentUser!.roles.first.name,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ],
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    List<Widget> actionsList = [];

    // Aggiungi azioni personalizzate
    if (actions != null) {
      actionsList.addAll(actions!);
    }

    if (showLogout) {
      // Informazioni utente e data/ora
      if (ResponsiveUtils.isDesktop(context)) {
        actionsList.addAll([
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Benvenuto, ${authProvider.currentUser?.name ?? 'Utente'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(width: 16.w),
        ]);
      }

      // Pulsante logout
      actionsList.add(
        IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: Icon(
            Icons.logout,
            color: Colors.white,
            size: 24.w,
          ),
          tooltip: 'Esci',
        ),
      );
    }

    return actionsList.isEmpty ? null : actionsList;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Text('Conferma Logout'),
          content: const Text('Sei sicuro di voler effettuare il logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Esci'),
            ),
          ],
        );
      },
    );
  }
}
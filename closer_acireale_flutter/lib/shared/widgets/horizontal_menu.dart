import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';

class HorizontalMenu extends StatelessWidget {
  final String currentRoute;

  const HorizontalMenu({
    super.key,
    required this.currentRoute,
  });

  static const List<MenuItemData> menuItems = [
    MenuItemData(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    MenuItemData(
      icon: Icons.people,
      label: 'Utenti',
      route: '/users',
      requiredPermission: 'users.view_all',
    ),
    MenuItemData(
      icon: Icons.campaign,
      label: 'Campagne',
      route: '/campaigns',
      requiredPermission: 'campaign.view_all',
    ),
    MenuItemData(
      icon: Icons.how_to_vote,
      label: 'Candidati',
      route: '/candidates',
      requiredPermission: 'candidates.view_all',
    ),
    MenuItemData(
      icon: Icons.analytics,
      label: 'Grafiche',
      route: '/graphics',
      requiredPermission: 'media.view_all',
    ),
    MenuItemData(
      icon: Icons.admin_panel_settings,
      label: 'Ruoli',
      route: '/roles',
      requiredPermission: 'roles.view_all',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Filtra gli item in base ai permessi
    final filteredMenuItems = menuItems.where((item) {
      if (item.requiredPermission == null) return true;
      return authProvider.checkPermissionFromUser(item.requiredPermission!);
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getSpacing(context,
            mobileSpacing: 16, tabletSpacing: 24, desktopSpacing: 32),
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ResponsiveUtils.isMobile(context)
          ? _buildMobileMenu(context, filteredMenuItems)
          : _buildDesktopMenu(context, filteredMenuItems),
    );
  }

  Widget _buildMobileMenu(BuildContext context, List<MenuItemData> items) {
    return Column(
      children: items.map((item) => _buildMenuItem(context, item)).toList(),
    );
  }

  Widget _buildDesktopMenu(BuildContext context, List<MenuItemData> items) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = 140.0;
          final maxItems = (constraints.maxWidth / itemWidth).floor();

          if (items.length <= maxItems) {
            return Wrap(
              spacing: 8.w,
              children: items.map((item) => _buildDesktopMenuItem(context, item)).toList(),
            );
          } else {
            final visibleItems = items.take(maxItems - 1).toList();
            final hiddenItems = items.skip(maxItems - 1).toList();

            return Row(
              children: [
                ...visibleItems.map((item) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildDesktopMenuItem(context, item),
                )),
                _buildMoreDropdown(context, hiddenItems),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItemData item) {
    final isActive = currentRoute == item.route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: isActive ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20.w,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textMedium,
              ),
              SizedBox(width: 12.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppTheme.primaryBlue : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopMenuItem(BuildContext context, MenuItemData item) {
    final isActive = currentRoute == item.route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.blueIndigoGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 18.w,
                color: isActive ? Colors.white : AppTheme.textMedium,
              ),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreDropdown(BuildContext context, List<MenuItemData> items) {
    return PopupMenuButton<MenuItemData>(
      onSelected: (item) => context.go(item.route),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem<MenuItemData>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon, size: 18.w, color: AppTheme.textMedium),
            SizedBox(width: 12.w),
            Text(item.label),
          ],
        ),
      ))
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.textLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.more_horiz,
              size: 18.w,
              color: AppTheme.textMedium,
            ),
            SizedBox(width: 8.w),
            Text(
              'Altro',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.w,
              color: AppTheme.textMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final String route;
  final String? requiredPermission;

  const MenuItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.requiredPermission,
  });
}
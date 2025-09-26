import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Importante: riduce l'altezza della Column
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Ruoli
            if (user.roles.isNotEmpty)
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: user.roles.take(3).map((role) {
                  final roleColor = Color(int.parse(role.color.replaceFirst('#', '0xFF')));
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.15),
                      border: Border.all(color: roleColor, width: 1.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      role.name,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

            if (user.roles.length > 3)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  '+${user.roles.length - 3} altri',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ),

            if (user.createdAt != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  'Registrato: ${_formatDate(user.createdAt!)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ),

            // Divider + Pulsanti
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Divider(color: AppTheme.borderLight, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 18.w),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                    padding: EdgeInsets.all(8.w),
                    minimumSize: Size(32.w, 32.h),
                  ),
                  tooltip: 'Modifica utente',
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 18.w),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.errorRed.withOpacity(0.1),
                    foregroundColor: AppTheme.errorRed,
                    padding: EdgeInsets.all(8.w),
                    minimumSize: Size(32.w, 32.h),
                  ),
                  tooltip: 'Elimina utente',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
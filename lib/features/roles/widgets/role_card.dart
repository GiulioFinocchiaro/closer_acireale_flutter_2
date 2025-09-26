import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/models/role_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

class RoleCard extends StatelessWidget {
  final RoleModel role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoleCard({
    super.key,
    required this.role,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          top: BorderSide(
            color: _getColorFromString(role.color),
            width: 4.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nome ruolo
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Livello: ${role.level}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                              color: _getColorFromString(role.color),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Sezione permessi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permessi:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: role.permissions.isNotEmpty
                        ? Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children: role.permissions.take(6).map((permission) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  permission.display_name,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              );
                            }).toList()
                              ..addAll(
                                role.permissions.length > 6
                                    ? [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            '+${role.permissions.length - 6}',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [],
                              ),
                          )
                        : Center(
                            child: Text(
                              'Nessun permesso',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textMedium,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Bottoni azioni
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Modifica',
                    icon: Icons.edit,
                    onPressed: onEdit,
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'Elimina',
                    icon: Icons.delete,
                    onPressed: onDelete,
                    backgroundColor: Colors.red,
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    try {
      // Rimuovi # se presente
      String hexColor = colorString.replaceAll('#', '');
      
      // Assicurati che la stringa sia di 6 caratteri
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
      
      // Fallback al colore di default
      return AppTheme.primaryBlue;
    } catch (e) {
      // Fallback al colore di default in caso di errore
      return AppTheme.primaryBlue;
    }
  }
}
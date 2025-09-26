import 'dart:convert';

import 'package:closer_acireale_flutter/core/models/school_model.dart';
import 'package:closer_acireale_flutter/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/providers/schools_provider.dart';
import '../../../shared/widgets/confirm_delete_modal.dart';
import '../../../shared/widgets/custom_modal.dart';
import '../screens/dashboard_screen.dart';

class SchoolsOverview extends StatelessWidget {
  const SchoolsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolsProvider = context.watch<SchoolsProvider>();

    // Mostra loader se le scuole non sono ancora caricate
    if (schoolsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schools = schoolsProvider.schools;

    return Container(
      padding: EdgeInsets.all(24.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panoramica Scuole',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          ResponsiveUtils.isMobile(context)
              ? _buildMobileLayout(context, schools)
              : _buildDesktopLayout(context, schools),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List schools) {
    return Column(
      children: schools.map((school) => _buildSchoolCard(context, school)).toList(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List schools) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 3,
      ),
      itemCount: schools.length,
      itemBuilder: (context, index) => _buildSchoolCard(context, schools[index]),
    );
  }

  Widget _buildSchoolCard(BuildContext context, SchoolModel school) {
    final name = school.school_name ?? 'N/A';
    final color = AppTheme.primaryBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('school_selected', jsonEncode(school.toJson()));

        context.go('/dashboard');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.school,
                size: 20.w,
                color: color,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${school.candidates_per_school.toString()} candidati • ${school.active_campaigns_per_school.toString()} campagne attive',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                  onPressed: () => _showEditSchool(context, school),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                  onPressed: () => _showDeleteSchoolModal(context, school),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSchool(BuildContext context, SchoolModel school) {
    final TextEditingController nameController = TextEditingController(text: school.school_name);
    final TextEditingController listController = TextEditingController(text: school.list_name);

    showDialog(
      context: context,
      builder: (context) => CustomModal(
        title: 'Modifica Scuola: ${school.school_name}',
        fields: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome scuola'),
          ),
          TextField(
            controller: listController,
            decoration: const InputDecoration(labelText: 'Nome lista'),
          ),
        ],
        confirmText: 'Modifica Scuola',
        onConfirm: () async {
          final name = nameController.text;
          final list = listController.text;

          if (name.isEmpty || list.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('I parametri non possono essere vuoti')),
            );
            return;
          }
          // salva i dati
          try {
            // chiamata al provider per aggiornare
            await Provider.of<SchoolsProvider>(context, listen: false)
                .updateSchool(school.id, name, list);

            Navigator.of(context).pop(); // chiudi il modal

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scuola aggiornata: $name')),
            );
          } catch (e) {
            // gestione errori runtime / API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore durante l\'aggiornamento: $e')),
            );
          }
        },
        cancelText: 'Annulla',
      ),
    );
  }

  void _showDeleteSchoolModal(BuildContext context, SchoolModel school) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteModal(
        message: 'Sei sicuro di voler eliminare la scuola "${school.school_name}"?',
        onConfirm: () {
          try {
            Provider.of<SchoolsProvider>(context, listen: false)
                .deleteSchool(school.id);
            Navigator.of(context).pop(); // chiudi modal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scuola "${school.school_name}" eliminata')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
            );
          }
        },
      ),
    );
  }

}
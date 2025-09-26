import 'dart:convert';
import 'package:closer_acireale_flutter/core/models/material_model.dart';
import 'package:closer_acireale_flutter/core/models/school_model.dart';
import 'package:closer_acireale_flutter/core/providers/role_provider.dart';
import 'package:closer_acireale_flutter/core/providers/schools_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/horizontal_menu.dart';
import '../widgets/stats_card.dart';
import '../widgets/dashboard_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SchoolModel? school;

  Future<void> _handlerGetSelectedSchool() async {
    final schoolProvider = Provider.of<SchoolsProvider>(
        context,
        listen: false
    );
    await schoolProvider.getSingleSchool(school!.id);
    school = schoolProvider.schoolSelected;
  }

  @override
  void initState()  {
    super.initState();
    _loadSelectedSchool();
  }

  Future<void> _loadSelectedSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolString = prefs.getString('school_selected');
    Provider.of<RoleProvider>(context, listen: false).initialize();
    if (schoolString != null) {
      setState(() {
        school = SchoolModel.fromJson(jsonDecode(schoolString));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handlerGetSelectedSchool();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (school == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const HorizontalMenu(currentRoute: '/dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildStatsGrid(context),
                  SizedBox(height: 32.h),
                  _buildMainContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'Benvenuto nella Dashboard della scuola: ${school!.school_name}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Qui puoi visualizzare le metriche principali e gestire le tue operazioni.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ).sp,
              color: AppTheme.textMedium,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppTheme.primaryBlue,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Il contenuto di questa area si adatterà in base alla selezione del menu.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final schoolsProvider = context.watch<SchoolsProvider>();
    final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(
      context,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: ResponsiveUtils.isMobile(context) ? 2.5 : 1.8,
      children: [
        StatsCard(
          title: 'Utenti Totali',
          value: schoolsProvider.totalUsersSingleSchool.toString(),
          icon: Icons.people,
          color: AppTheme.primaryBlue,
        ),
        StatsCard(
          title: 'Campagne Attive',
          value: schoolsProvider.totalActiveCampaignsSingleSchool.toString(),
          icon: Icons.campaign,
          color: AppTheme.successGreen,
        ),
        StatsCard(
          title: 'Candidati',
          value: schoolsProvider.totalCandidatesSingleSchool.toString(),
          icon: Icons.how_to_vote,
          color: AppTheme.warningYellow,
        ),
        StatsCard(
          title: 'Materiali',
          value: schoolsProvider.totalMaterialsSingleSchool.toString(),
          icon: Icons.image,
          color: AppTheme.secondaryPurple,
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildActivityChart(),
          SizedBox(height: 24.h),
          _buildMaterials(context.watch<SchoolsProvider>().lastestMaterialSingleSchool),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildActivityChart()),
        SizedBox(width: 24.w),
        Expanded(child: _buildMaterials(context.watch<SchoolsProvider>().lastestMaterialSingleSchool)),
      ],
    );
  }

  Widget _buildActivityChart() {
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
            'Attività Recenti',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          const DashboardChart(),
        ],
      ),
    );
  }

  Widget _buildMaterials(dynamic lastestMaterialSingleSchool) {
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
            'Prossimi materiali',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          lastestMaterialSingleSchool.isEmpty
              ? Text(
            'Nessun materiale disponibile',
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textMedium),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lastestMaterialSingleSchool.length,
            separatorBuilder: (context, index) => Divider(height: 16.h),
            itemBuilder: (context, index) {
              final MaterialModal material = lastestMaterialSingleSchool[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.material_name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tipo: ${material.graphic.asset_type}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Descrizione: ${material.graphic.description}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Pubblicato il: ${material.published_at != null ? DateFormat('dd/MM/yyyy').format(material.published_at!) : 'N/A'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, String time) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.w, color: AppTheme.primaryBlue),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              Text(subtitle,
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textMedium)),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight)),
      ],
    );
  }
}
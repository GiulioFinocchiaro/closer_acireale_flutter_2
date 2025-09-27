import 'package:closer_acireale_flutter/core/providers/auth_provider.dart';
import 'package:closer_acireale_flutter/core/providers/schools_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/schools_overview.dart';
import '../widgets/add_school_modal.dart';

class DashboardSchoolsScreen extends StatefulWidget {
  const DashboardSchoolsScreen({super.key});

  @override
  State<DashboardSchoolsScreen> createState() => _DashboardSchoolsScreenState();
}

class _DashboardSchoolsScreenState extends State<DashboardSchoolsScreen> {

  Future<void> _handleDashboard() async {
    final schoolsProvider = Provider.of<SchoolsProvider>(
        context, listen: false);
    await schoolsProvider.initialize();
    await schoolsProvider.getSchool();
  }

  void _showAddSchoolModal() {
    showDialog(
      context: context,
      builder: (context) => const AddSchoolModal(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolsProvider = context.watch<SchoolsProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard Scuole'),
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildSchoolsStatsGrid(context, schoolsProvider),
                  SizedBox(height: 32.h),
                  const SchoolsOverview(),
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
        gradient: AppTheme.blueIndigoGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.school, size: 24.w, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestione Scuole',
                  style: TextStyle(
                    fontSize: ResponsiveUtils
                        .getResponsiveFontSize(
                        context, mobile: 20, tablet: 24, desktop: 28)
                        .sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Dashboard completa per la supervisione delle scuole',
                  style: TextStyle(
                    fontSize: ResponsiveUtils
                        .getResponsiveFontSize(
                        context, mobile: 14, tablet: 16, desktop: 18)
                        .sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsStatsGrid(BuildContext context,
      SchoolsProvider schoolsProvider) {
    if (schoolsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (schoolsProvider.errorMessage != null) {
      return Center(child: Text(schoolsProvider.errorMessage!));
    }

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
          title: 'Scuole Totali',
          value: schoolsProvider.schools.length.toString(),
          icon: Icons.school,
          color: AppTheme.primaryBlue,
        ),
        StatsCard(
          title: 'Candidati Totali',
          value: schoolsProvider.totalCandidates.toString(),
          icon: Icons.groups,
          color: AppTheme.successGreen,
        ),
        StatsCard(
          title: 'Campagne Attive',
          value: schoolsProvider.totalActiveCampaigns.toString(),
          icon: Icons.how_to_vote,
          color: AppTheme.warningYellow,
        ),
        StatsCard(
          title: 'Materiali Totali',
          value: schoolsProvider.totalMaterials.toString(),
          icon: Icons.image,
          color: AppTheme.secondaryPurple,
        ),
      ],
    );
  }
}
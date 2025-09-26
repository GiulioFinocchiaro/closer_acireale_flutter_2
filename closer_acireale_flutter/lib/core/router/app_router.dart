import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/dashboard_schools_screen.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/campaigns/screens/campaigns_screen.dart';
import '../../features/campaigns/screens/single_campaign_screen.dart';
import '../../features/candidates/screens/candidates_screen.dart';
import '../../features/graphics/screens/graphics_screen.dart';
import '../../features/roles/screens/roles_screen.dart';
import '../models/school_model.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      
      if (!isLoggedIn && state.uri.toString() != '/login') {
        return '/login';
      }
      
      if (isLoggedIn && state.uri.toString() == '/login') {
        // Verifica permessi per decidere dashboard
        return authProvider.hasSchoolPermissions ? '/dashboard-schools' : '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state)  => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard-schools',
        name: 'dashboard-schools',
        builder: (context, state) => const DashboardSchoolsScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/campaigns',
        name: 'campaigns',
        builder: (context, state) => const CampaignsScreen(),
        routes: [
          GoRoute(
            path: 'singlecampaign',
            name: 'singlecampaign',
            builder: (context, state) => SingleCampaignScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/candidates',
        name: 'candidates',
        builder: (context, state) => const CandidatesScreen(),
      ),
      GoRoute(
        path: '/graphics',
        name: 'graphics',
        builder: (context, state) => const GraphicsScreen(),
      ),
      GoRoute(
        path: '/roles',
        name: 'roles',
        builder: (context, state) => const RolesScreen(),
      ),
    ],
  );
}
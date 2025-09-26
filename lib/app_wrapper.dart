import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Providers
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/schools_provider.dart';
import 'core/providers/role_provider.dart';
import 'core/providers/campaigns_provider.dart';
import 'core/providers/graphics_provider.dart';
import 'core/providers/candidates_provider.dart';
import 'core/providers/error_provider.dart';
import 'core/providers/loading_provider.dart';

// Router e theme
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Componenti globali
import 'shared/widgets/global_error_modal.dart';
import 'shared/widgets/global_loading_modal.dart';
import 'shared/widgets/token_expired_modal.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // Design basato su desktop come originale
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Providers core
            ChangeNotifierProvider(create: (_) => ErrorProvider()),
            ChangeNotifierProvider(create: (_) => LoadingProvider()),
            
            // Providers esistenti
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => SchoolsProvider()),
            ChangeNotifierProvider(create: (_) => RoleProvider()),
            ChangeNotifierProvider(create: (_) => CampaignsProvider()),
            ChangeNotifierProvider(create: (_) => GraphicsProvider()),
            ChangeNotifierProvider(create: (_) => CandidatesProvider()),
          ],
          child: MaterialApp.router(
            title: 'Closer Acireale',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            // Builder per overlay globali
            builder: (context, child) {
              return Stack(
                children: [
                  // App principale
                  child ?? const SizedBox.shrink(),
                  
                  // Overlay globali (sempre in primo piano)
                  const GlobalLoadingModal(),
                  const GlobalErrorModal(),
                  const TokenExpiredModal(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
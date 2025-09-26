class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://www.closeracireale.it/backend/public/api';
  static const String platformName = 'Closer Acireale';
  static const String cdnUrl = 'https://www.closeracireale.it/cdn';
  
  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String rolesKey = 'roles';
  
  // Permissions
  static const String schoolsViewAllPermission = 'schools.view_all';
  
  // Routes
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String dashboardSchoolsRoute = '/dashboard-schools';
  static const String usersRoute = '/users';
  static const String campaignsRoute = '/campaigns';
  static const String candidatesRoute = '/candidates';
  static const String graphicsRoute = '/graphics';
  static const String rolesRoute = '/roles';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardPadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 6.0;
  
  // Breakpoints per design responsivo
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Network Settings
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Error Messages
  static const String networkErrorMessage = 'Errore di connessione. Controlla la tua connessione internet.';
  static const String timeoutErrorMessage = 'La richiesta ha impiegato troppo tempo. Riprova.';
  static const String unknownErrorMessage = 'Si è verificato un errore imprevisto.';
  static const String unauthorizedErrorMessage = 'Non sei autorizzato ad accedere a questa risorsa.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Accesso effettuato con successo!';
  static const String logoutSuccessMessage = 'Disconnessione effettuata con successo!';
  static const String saveSuccessMessage = 'Salvato con successo!';
  static const String deleteSuccessMessage = 'Eliminato con successo!';
}
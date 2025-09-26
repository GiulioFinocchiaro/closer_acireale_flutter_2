import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  UserModel? _currentUser;
  bool _hasSchoolPermissions = false;
  String? _errorMessage;
  bool _showTokenExpiredModal = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get hasSchoolPermissions => _hasSchoolPermissions;
  String? get errorMessage => _errorMessage;
  bool get showTokenExpiredModal => _showTokenExpiredModal;

  // Initialize - controlla se l'utente è già autenticato
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        _token = token;
        _isAuthenticated = true;
        
        // Verifica se il token è ancora valido
        await _loadUserData();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Errore durante l\'inizializzazione: $e');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final loginData = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (loginData['token'] != null) {
        _token = loginData['token'];
        await _saveToken(_token!);
        
        // Carica dati utente e permessi
        await _loadUserData();
        _checkSchoolPermissionsFromUser();
        
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Errore durante il login: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      _token = null;
      _currentUser = null;
      _isAuthenticated = false;
      _hasSchoolPermissions = false;
      _clearError();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Errore durante il logout: $e');
    }
  }

  // Carica dati utente
  Future<void> _loadUserData() async {
    try {
      if (_token == null) return;
      
      final userData = await _apiService.get('/auth/me', token: _token);
      _currentUser = UserModel.fromJson(userData);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Errore nel caricamento dati utente: $e');
      // Verifica se è un errore di token scaduto
      handleApiError(e);
      
      // Se è un errore di autenticazione, effettua logout
      String errorString = e.toString();
      if (errorString.contains('401') || errorString.contains('Unauthorized')) {
        await logout();
      }
    }
  }

  void _checkSchoolPermissionsFromUser() {
    for (var role in this._currentUser!.roles) {
      for (var perm in role.permissions) {
        if (perm.name == 'schools.view_all') {
          _hasSchoolPermissions = true;
          return;
        }
      }
    }
    _hasSchoolPermissions = false;
  }

  // Salva token in storage locale
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Gestione token scaduto
  void showTokenExpiredModal() {
    _showTokenExpiredModal = true;
    notifyListeners();
  }

  void hideTokenExpiredModal() {
    _showTokenExpiredModal = false;
    notifyListeners();
  }

  // Verifica se l'errore è relativo al token scaduto
  void handleApiError(dynamic error) {
    String errorString = error.toString();
    
    if (errorString.contains('401') || 
        errorString.contains('Unauthorized') ||
        errorString.contains('Token expired') ||
        errorString.contains('Invalid token')) {
      showTokenExpiredModal();
    } else {
      _setError('Errore: $errorString');
    }
  }
}
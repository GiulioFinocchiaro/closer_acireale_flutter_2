import 'package:closer_acireale_flutter/core/models/role_model.dart';
import 'package:closer_acireale_flutter/core/providers/schools_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _selectedUser;

  // Getters
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get selectedUser => _selectedUser;

  // Carica tutti gli utenti
  Future<void> loadUsers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _setLoading(true);
      _clearError();

      // Prendo la scuola selezionata dal provider
      final schoolsProvider = Provider.of<SchoolsProvider>(context, listen: false);
      final selectedSchool = schoolsProvider.schoolSelected;
      if (selectedSchool == null) {
        _setError('Nessuna scuola selezionata');
        _setLoading(false);
        return;
      }

      final schoolId = selectedSchool.id;

      // Chiamo l'API passando l'id della scuola
      final response = await _apiService.post(
        '/users/get_by_school',
        {'school_id': schoolId},
        token: prefs.getString('token'),
      );

      if (response['users'] != null) {
        _users = (response['users'] as List<dynamic>)
            .map((json) => UserModel.fromJson(json))
            .toList();

      } else {
        _users = [];
      }

      print("Users ${_users.toString()}");

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento utenti: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Aggiungi nuovo utente
  Future<bool> addUser({
    required String name,
    required String email,
    required List<RoleModel> roles,
    required int schoolId,
    required String? token,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'school': schoolId,
        'role': roles.map((r) => r.id).toList(),
      }, token: token);

      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Errore nella creazione utente: ${e.toString()}');
      print("Errore nella registrazione dell'utente ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  // Elimina utente
  Future<bool> deleteUser(int? userId) async {
    try {
      _setLoading(true);
      _clearError();

      final prefs = await SharedPreferences.getInstance();

      await _apiService.delete('/users/delete',
          data: {'id': userId},
          token: prefs.getString('token')
      );
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Errore nell\'eliminazione utente: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateUser(
      int? userId,
      String name,
      String email,
      bool resetPassword,
      List<RoleModel> roles,
      int schoolId,
      {String? token}
      ) async {
    try {
      _setLoading(true);
      _clearError();

      // Prepara i dati da inviare
      final data = {
        'id': userId,
        'school_id': schoolId,
        'name': name,
        'email': email,
        'password': resetPassword ? 'RESET_PASSWORD' : null, // backend deve gestire il reset
        'role': roles.map((r) => r.id).toList(), // inviamo solo gli ID dei ruoli
      };

      // Chiamata API
      final response = await _apiService.put(
        '/users/update',
        data,
        token: token,
      );

    } catch (e) {
      print("Errore $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Seleziona utente per modifica
  void selectUser(UserModel? user) {
    _selectedUser = user;
    notifyListeners();
  }

  // Cerca utenti per nome o email
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) => 
      user.name.toLowerCase().contains(lowercaseQuery) ||
      user.email.toLowerCase().contains(lowercaseQuery)
    ).toList();
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
  }

  // Reset provider state
  void reset() {
    _users.clear();
    _selectedUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
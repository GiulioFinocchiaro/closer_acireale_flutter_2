import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/role_model.dart';
import '../models/school_model.dart';
import '../services/api_service.dart';

class RoleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  int? _selectedSchoolId;

  List<RoleModel> _roles = [];
  List<String> _availablePermissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<RoleModel> get roles => _roles;
  List<String> get availablePermissions => _availablePermissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inizializza token e scuola selezionata
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    final schoolSelectedString = prefs.getString('school_selected');
    if (schoolSelectedString != null) {
      final school = SchoolModel.fromJson(jsonDecode(schoolSelectedString));
      _selectedSchoolId = school.id;
    }
  }

  /// Recupera i ruoli dal backend
  Future<void> getRoles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rolesData = await _apiService.post(
        '/roles/roles_by_level_or_lower',
        {'school_id': _selectedSchoolId},
        token: _token,
      );

      // Mappo il JSON in oggetti RoleModel
      _roles = (rolesData as List)
          .map((r) => RoleModel.fromJson(r))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il caricamento dei ruoli: $e';
      notifyListeners();
    }
  }

  /// Recupera i permessi disponibili
  Future<void> getAvailablePermissions() async {
    try {
      final permissionsData = await _apiService.get('/roles/mine_permissions', token: _token);
      _availablePermissions = List<String>.from(permissionsData);
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dei permessi: $e';
      notifyListeners();
    }
  }

  /// Aggiunge un nuovo ruolo
  Future<bool> addRole({
    required String name,
    required int privilegeLevel,
    required String color,
    required List<String> permissions,
  }) async {
    try {
      await _apiService.post(
        '/roles/add',
        {
          'name': name,
          'privilege_level': privilegeLevel,
          'color': color,
          'permissions': permissions,
        },
        token: _token,
      );

      await getRoles(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'aggiunta del ruolo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Aggiorna un ruolo esistente
  Future<bool> updateRole({
    required int id,
    required String name,
    required int privilegeLevel,
    required String color,
    required List<String> permissions,
  }) async {
    try {
      await _apiService.put(
        '/roles/update',
        {
          'id': id,
          'name': name,
          'privilege_level': privilegeLevel,
          'color': color,
          'permissions': permissions,
        },
        token: _token,
      );

      await getRoles(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'aggiornamento del ruolo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un ruolo
  Future<bool> deleteRole(int id) async {
    try {
      await _apiService.delete(
        '/roles/delete',
        data: {'id': id},
        token: _token,
      );

      await getRoles(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'eliminazione del ruolo: $e';
      notifyListeners();
      return false;
    }
  }

  // -----------------------------
  // Gestione errori
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
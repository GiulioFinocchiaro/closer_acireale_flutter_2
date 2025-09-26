import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate_model.dart';
import '../models/school_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class CandidatesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  int? _selectedSchoolId;
  bool _isSuperAdmin = false;

  List<Candidate> _candidates = [];
  List<UserModel> _eligibleUsers = [];
  bool _isLoading = false;
  bool _isLoadingUsers = false;
  String? _errorMessage;

  // Getters
  List<Candidate> get candidates => _candidates;
  List<UserModel> get eligibleUsers => _eligibleUsers;
  bool get isLoading => _isLoading;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get errorMessage => _errorMessage;
  bool get isSuperAdmin => _isSuperAdmin;

  /// Inizializza token e scuola selezionata
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    final schoolSelectedString = prefs.getString('school_selected');
    if (schoolSelectedString != null) {
      final school = SchoolModel.fromJson(jsonDecode(schoolSelectedString));
      _selectedSchoolId = school.id;
    }

    await _checkUserPermissions();
  }

  Future<void> _checkUserPermissions() async {
    try {
      _isSuperAdmin = _selectedSchoolId != null;
    } catch (e) {
      _isSuperAdmin = false;
    }
  }

  /// Recupera i candidati dal backend
  Future<void> getCandidates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _isSuperAdmin ? {'school_id': _selectedSchoolId} : null;
      
      final candidatesData = await _apiService.post(
        '/candidates/get_by_school',
        data ?? {},
        token: _token,
      );

      _candidates = (candidatesData as List)
          .map((c) => Candidate.fromJson(c))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il caricamento dei candidati: $e';
      notifyListeners();
    }
  }

  /// Recupera utenti idonei per la candidatura
  Future<void> getEligibleUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      final data = _isSuperAdmin ? {'school_id': _selectedSchoolId} : null;
      
      final usersData = await _apiService.post(
        '/candidates/get_eligible_candidates_by_school',
        data ?? {},
        token: _token,
      );

      _eligibleUsers = (usersData as List)
          .map((u) => UserModel.fromJson(u))
          .toList();

      _isLoadingUsers = false;
      notifyListeners();
    } catch (e) {
      _isLoadingUsers = false;
      _errorMessage = 'Errore durante il caricamento degli utenti: $e';
      notifyListeners();
    }
  }

  /// Aggiunge un nuovo candidato
  Future<bool> addCandidate({
    required int userId,
    required String classYear,
    required String description,
    String? photo,
    String? manifesto,
  }) async {
    try {
      await _apiService.post(
        '/candidates/addCandidate',
        {
          'user_id': userId,
          'class_year': classYear,
          'description': description,
          'photo': photo,
          'manifesto': manifesto,
        },
        token: _token,
      );

      await getCandidates(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'aggiunta del candidato: $e';
      notifyListeners();
      return false;
    }
  }

  /// Aggiorna un candidato esistente
  Future<bool> updateCandidate({
    required int id,
    required String classYear,
    required String description,
    String? photo,
    String? manifesto,
  }) async {
    try {
      await _apiService.put(
        '/candidates/updateCandidate',
        {
          'id': id,
          'class_year': classYear,
          'description': description,
          'photo': photo,
          'manifesto': manifesto,
        },
        token: _token,
      );

      await getCandidates(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'aggiornamento del candidato: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un candidato
  Future<bool> deleteCandidate(int id) async {
    try {
      await _apiService.delete(
        '/candidates/deleteCandidate',
        data: {'id': id},
        token: _token,
      );

      await getCandidates(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'eliminazione del candidato: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
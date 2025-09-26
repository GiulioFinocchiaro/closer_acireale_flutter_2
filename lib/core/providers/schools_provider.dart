import 'package:closer_acireale_flutter/core/models/material_model.dart';
import 'package:closer_acireale_flutter/core/models/school_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SchoolsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  String? _token;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  int totalCandidates = 0;
  int totalActiveCampaigns = 0;
  int totalMaterials = 0;
  List<SchoolModel> schools = [];

  int totalCandidatesSingleSchool = 0;
  int totalActiveCampaignsSingleSchool = 0;
  int totalMaterialsSingleSchool = 0;
  int totalUsersSingleSchool = 0;
  List<MaterialModal> lastestMaterialSingleSchool = [];
  late SchoolModel schoolSelected;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _isAuthenticated = _token != null;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> getSchool() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schoolsData = await _apiService.get(
        '/schools/get_all',
        token: _token,
      );

      final jsonTotals = schoolsData["totals"] ?? {};

      totalCandidates = int.tryParse(jsonTotals['total_candidates']?? '0')!;
      totalActiveCampaigns = int.tryParse(jsonTotals['total_active_campaigns'] ?? '0')!;
      totalMaterials = int.tryParse(jsonTotals['total_materials'] ?? '0')!;


      schools = (schoolsData["schools"] as List<dynamic>?)
          ?.map((e) => SchoolModel.fromJson(e))
          .toList() ??
          [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il caricamento: $e';
      notifyListeners();
    }
  }

  Future<void> updateSchool(int id, String name, String list) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.put(
        '/schools/update',
        {'school_name': name, 'list_name': list, 'id': id},
        token: _token
      );
      getSchool();
      _isLoading = false;
      notifyListeners();
    } catch (e){
      _isLoading = false;
      _errorMessage = 'Errore durante la modifica della scuola: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSchool(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.delete(
        '/schools/delete',
        data: {'id': id},
        token: _token
      );
      getSchool();
      _isLoading = false;
      notifyListeners();
    } catch(e){
      _isLoading = false;
      _errorMessage = 'Errore durante l\'eliminazione della scuola: $e';
      notifyListeners();
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

  Future<void> getSingleSchool(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final schoolData = await _apiService.get(
        '/schools/get_single_school_mine?school_id=$id',
        token: _token,
      );

      // Aggiorna statistiche
      totalActiveCampaignsSingleSchool = schoolData['active_campaigns'] is int
          ? schoolData['active_campaigns']
          : int.tryParse(schoolData['active_campaigns'])
          ?? 0;
      totalCandidatesSingleSchool = schoolData['total_candidates'] is int
          ? schoolData['total_candidates']
          : int.tryParse(schoolData['total_candidates'])
          ?? 0;
      totalMaterialsSingleSchool = schoolData['total_materials'] is int
          ? schoolData['total_materials']
          : int.tryParse(schoolData['total_materials'])
          ?? 0;
      totalUsersSingleSchool = schoolData['total_users'] is int
          ? schoolData['total_users']
          : int.tryParse(schoolData['total_users'])
          ?? 0;

      // Aggiorna scuola selezionata
      schoolSelected = SchoolModel.fromJson(schoolData['school']);

      // Mappa gli ultimi 5 materiali
      final latestMaterialsJson = schoolData['latest_materials'] as List<dynamic>? ?? [];
      lastestMaterialSingleSchool = latestMaterialsJson
          .map((json) => MaterialModal.fromJson(json as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il caricamento della scuola: $e';
      notifyListeners();
    }
  }
}
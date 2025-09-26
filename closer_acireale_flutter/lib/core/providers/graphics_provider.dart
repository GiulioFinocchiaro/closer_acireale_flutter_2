import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/graphic_asset_model.dart';
import '../models/school_model.dart';
import '../services/api_service.dart';

class GraphicsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  int? _selectedSchoolId;
  bool _isSuperAdmin = false;

  List<GraphicAsset> _graphics = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GraphicAsset> get graphics => _graphics;
  bool get isLoading => _isLoading;
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

    // Check if user is super admin by trying to load user permissions
    await _checkUserPermissions();
  }

  Future<void> _checkUserPermissions() async {
    try {
      // This would be similar to how the original JS checks permissions
      // For now, we'll assume if selectedSchoolId exists, user has permissions
      _isSuperAdmin = _selectedSchoolId != null;
    } catch (e) {
      _isSuperAdmin = false;
    }
  }

  /// Recupera le grafiche dal backend
  Future<void> getGraphics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _selectedSchoolId != null ? {'school_id': _selectedSchoolId} : <String, dynamic>{};
      
      final graphicsData = await _apiService.post(
        '/media/get',
        data,
        token: _token,
      );

      _graphics = (graphicsData as List)
          .map((g) => GraphicAsset.fromJson(g))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore durante il caricamento delle grafiche: $e';
      notifyListeners();
    }
  }

  /// Carica un nuovo file grafico
  Future<bool> uploadGraphic({
    required Uint8List fileBytes,
    required String fileName,
    required String assetType,
    required String description,
  }) async {
    try {
      final data = <String, dynamic>{
        'file': fileBytes,
        'asset_type': assetType,
        'description': description,
      };

      if (_isSuperAdmin && _selectedSchoolId != null) {
        data['school_id'] = _selectedSchoolId;
      }

      await _apiService.post(
        '/media/upload',
        data,
        token: _token,
        isFormData: true,
      );

      await getGraphics(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento: $e';
      notifyListeners();
      return false;
    }
  }

  /// Aggiorna metadati di una grafica esistente
  Future<bool> updateGraphic({
    required int id,
    required String assetType,
    required String description,
  }) async {
    try {
      await _apiService.put(
        '/media/update',
        {
          'id': id,
          'asset_type': assetType,
          'description': description,
          'school_id': _selectedSchoolId,
        },
        token: _token,
      );

      await getGraphics(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'aggiornamento: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una grafica
  Future<bool> deleteGraphic(int id) async {
    try {
      final data = _selectedSchoolId != null 
          ? {'school_id': _selectedSchoolId, 'id': id}
          : {'id': id};
          
      await _apiService.delete(
        '/media/delete',
        data: data,
        token: _token,
      );

      await getGraphics(); // Ricarica la lista
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante l\'eliminazione: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
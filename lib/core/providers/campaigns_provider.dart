import 'package:flutter/foundation.dart';
import '../models/campaign_model.dart';
import '../models/graphic_asset_model.dart';
import '../services/campaigns_service.dart';

class CampaignsProvider with ChangeNotifier {
  final CampaignsService _campaignsService = CampaignsService();

  List<Campaign> _campaigns = [];
  Campaign? _selectedCampaign;
  List<GraphicAsset> _graphicAssets = [];
  bool _isLoading = false;
  String? _error;

  List<Campaign> get campaigns => _campaigns;
  Campaign? get selectedCampaign => _selectedCampaign;
  List<GraphicAsset> get graphicAssets => _graphicAssets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Fetch all campaigns
  Future<void> fetchCampaigns({int? schoolId, String? token}) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final campaignsData = await _campaignsService.getCampaigns(
        schoolId: schoolId, 
        token: token
      );
      
      _campaigns = (campaignsData as List)
          .map((json) => Campaign.fromJson(json))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch single campaign with details
  Future<void> fetchCampaignDetails({
    required int campaignId,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final campaignData = await _campaignsService.getSingleCampaign(
        campaignId: campaignId,
        schoolId: schoolId,
        token: token,
      );
      
      _selectedCampaign = Campaign.fromJson(campaignData);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new campaign
  Future<bool> createCampaign({
    required String title,
    required String description,
    required String status,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.createCampaign(
        title: title,
        description: description,
        status: status,
        schoolId: schoolId,
        token: token,
      );
      
      // Refresh campaigns list
      await fetchCampaigns(schoolId: schoolId, token: token);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update campaign
  Future<bool> updateCampaign({
    required int campaignId,
    required String title,
    required String description,
    required String status,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.updateCampaign(
        campaignId: campaignId,
        title: title,
        description: description,
        status: status,
        schoolId: schoolId,
        token: token,
      );
      
      // Refresh campaigns list
      await fetchCampaigns(schoolId: schoolId, token: token);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete campaign
  Future<bool> deleteCampaign({
    required int campaignId,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.deleteCampaign(
        campaignId: campaignId,
        schoolId: schoolId,
        token: token,
      );
      
      // Remove from local list
      _campaigns.removeWhere((campaign) => campaign.id == campaignId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch graphic assets
  Future<void> fetchGraphicAssets({int? schoolId, String? token}) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final assetsData = await _campaignsService.getGraphicAssets(
        schoolId: schoolId,
        token: token,
      );
      
      _graphicAssets = (assetsData as List)
          .map((json) => GraphicAsset.fromJson(json))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add material to campaign
  Future<bool> addMaterial({
    required int campaignId,
    required String materialName,
    required String publishedAt,
    required int graphicId,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.addMaterial(
        campaignId: campaignId,
        materialName: materialName,
        publishedAt: publishedAt,
        graphicId: graphicId,
        schoolId: schoolId,
        token: token,
      );
      
      // Refresh campaign details
      await fetchCampaignDetails(
        campaignId: campaignId,
        schoolId: schoolId,
        token: token,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add event to campaign
  Future<bool> addEvent({
    required int campaignId,
    required String eventName,
    required String eventDescription,
    required String eventDate,
    String? location,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.addEvent(
        campaignId: campaignId,
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: eventDate,
        location: location,
        schoolId: schoolId,
        token: token,
      );
      
      // Refresh campaign details
      await fetchCampaignDetails(
        campaignId: campaignId,
        schoolId: schoolId,
        token: token,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete material
  Future<bool> deleteMaterial({
    required int materialId,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.deleteMaterial(
        materialId: materialId,
        schoolId: schoolId,
        token: token,
      );
      
      // Update selected campaign materials
      if (_selectedCampaign != null && _selectedCampaign!.materials != null) {
        final updatedMaterials = _selectedCampaign!.materials!
            .where((material) => material.id != materialId)
            .toList();
        
        _selectedCampaign = _selectedCampaign!.copyWith(
          materials: updatedMaterials,
          materialsCount: updatedMaterials.length,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete event
  Future<bool> deleteEvent({
    required int eventId,
    int? schoolId,
    String? token,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _campaignsService.deleteEvent(
        eventId: eventId,
        schoolId: schoolId,
        token: token,
      );
      
      // Update selected campaign events
      if (_selectedCampaign != null && _selectedCampaign!.events != null) {
        final updatedEvents = _selectedCampaign!.events!
            .where((event) => event.id != eventId)
            .toList();
        
        _selectedCampaign = _selectedCampaign!.copyWith(
          events: updatedEvents,
          eventsCount: updatedEvents.length,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear selected campaign
  void clearSelectedCampaign() {
    _selectedCampaign = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
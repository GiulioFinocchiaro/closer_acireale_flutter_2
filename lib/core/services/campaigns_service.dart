import 'api_service.dart';

class CampaignsService {
  final ApiService _apiService = ApiService();

  // Get all campaigns
  Future<dynamic> getCampaigns({int? schoolId, String? token}) async {
    const endpoint = '/campaigns/get';
    final data = <String, dynamic>{};
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Get single campaign with details
  Future<dynamic> getSingleCampaign({
    required int campaignId,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/get_single';
    final data = <String, dynamic>{
      'id': campaignId,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Create new campaign
  Future<dynamic> createCampaign({
    required String title,
    required String description,
    required String status,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/add';
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Update campaign
  Future<dynamic> updateCampaign({
    required int campaignId,
    required String title,
    required String description,
    required String status,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/update';
    final data = <String, dynamic>{
      'id': campaignId,
      'title': title,
      'description': description,
      'status': status,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.put(endpoint, data, token: token);
  }

  // Delete campaign
  Future<dynamic> deleteCampaign({
    required int campaignId,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/delete';
    final data = <String, dynamic>{
      'id': campaignId,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.delete(endpoint, data: data, token: token);
  }

  // Get graphic assets
  Future<dynamic> getGraphicAssets({
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/materials/get_graphic_assets';
    final data = <String, dynamic>{};
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Add material to campaign
  Future<dynamic> addMaterial({
    required int campaignId,
    required String materialName,
    required String publishedAt,
    required int graphicId,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/materials/add';
    final data = <String, dynamic>{
      'campaign_id': campaignId,
      'material_name': materialName,
      'published_at': publishedAt,
      'graphic_id': graphicId,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Add event to campaign
  Future<dynamic> addEvent({
    required int campaignId,
    required String eventName,
    required String eventDescription,
    required String eventDate,
    String? location,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/events/add';
    final data = <String, dynamic>{
      'campaign_id': campaignId,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_date': eventDate,
    };
    
    if (location != null) {
      data['location'] = location;
    }
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.post(endpoint, data, token: token);
  }

  // Delete material
  Future<dynamic> deleteMaterial({
    required int materialId,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/materials/delete';
    final data = <String, dynamic>{
      'id': materialId,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.delete(endpoint, data: data, token: token);
  }

  // Delete event
  Future<dynamic> deleteEvent({
    required int eventId,
    int? schoolId,
    String? token,
  }) async {
    const endpoint = '/campaigns/events/delete';
    final data = <String, dynamic>{
      'id': eventId,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return await _apiService.delete(endpoint, data: data, token: token);
  }
}
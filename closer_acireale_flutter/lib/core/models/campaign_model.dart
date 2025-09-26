import 'package:closer_acireale_flutter/core/models/material_model.dart';

import 'candidate_model.dart';
import 'event_model.dart';

class Campaign {
  final int id;
  final String title;
  final String description;
  final String status; // 'draft' or 'activate'
  final String createdAt;
  final int? schoolId;
  final int eventsCount;
  final int materialsCount;
  final int candidatesCount;
  final List<MaterialModal>? materials;
  final List<Event>? events;
  final List<Candidate>? candidates;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.schoolId,
    this.eventsCount = 0,
    this.materialsCount = 0,
    this.candidatesCount = 0,
    this.materials,
    this.events,
    this.candidates,
  });

  bool get isDraft => status == 'draft';
  bool get isActive => status == 'activate';

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'] ?? '',
      schoolId: json['school_id'],
      eventsCount: json['events_count'] ?? 0,
      materialsCount: json['materials_count'] ?? 0,
      candidatesCount: json['candidates_count'] ?? 0,
      materials: json['materials'] != null 
        ? (json['materials'] as List).map((e) => MaterialModal.fromJson(e)).toList()
        : null,
      events: json['events'] != null
        ? (json['events'] as List).map((e) => Event.fromJson(e)).toList()
        : null,
      candidates: json['candidates'] != null
        ? (json['candidates'] as List).map((e) => Candidate.fromJson(e)).toList()
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
    
    if (schoolId != null) {
      data['school_id'] = schoolId;
    }
    
    return data;
  }

  Campaign copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? createdAt,
    int? schoolId,
    int? eventsCount,
    int? materialsCount,
    int? candidatesCount,
    List<MaterialModal>? materials,
    List<Event>? events,
    List<Candidate>? candidates,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      schoolId: schoolId ?? this.schoolId,
      eventsCount: eventsCount ?? this.eventsCount,
      materialsCount: materialsCount ?? this.materialsCount,
      candidatesCount: candidatesCount ?? this.candidatesCount,
      materials: materials ?? this.materials,
      events: events ?? this.events,
      candidates: candidates ?? this.candidates,
    );
  }
}
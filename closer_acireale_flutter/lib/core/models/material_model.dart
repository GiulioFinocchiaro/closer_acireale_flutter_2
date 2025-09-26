import 'package:closer_acireale_flutter/core/models/graphic_asset_model.dart';

class MaterialModal {
  final int id;
  final String material_name;
  final DateTime? published_at;
  final int created_by;
  final GraphicAsset graphic;

  MaterialModal({
    required this.id,
    required this.material_name,
    required this.published_at,
    required this.created_by,
    required this.graphic,
  });

  factory MaterialModal.fromJson(Map<String, dynamic> json) {
    // creo l’oggetto graphic
    final graphic = GraphicAsset(
      id: json['graphic_id'] is int
          ? json['graphic_id']
          : int.tryParse(json['graphic_id']?.toString() ?? '') ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      asset_type: json['asset_type'] ?? '',
      description: json['description'] ?? '',
    );

    return MaterialModal(
      id: json['material_id'] is int
          ? json['material_id']
          : int.tryParse(json['material_id']?.toString() ?? '') ?? 0,
      material_name: json['material_name'] ?? '',
      published_at: json['published_at'] != null &&
          json['published_at'].toString().isNotEmpty
          ? DateTime.parse(json['published_at']).toLocal()
          : null,
      created_by: json['created_by'] is int
          ? json['created_by']
          : int.tryParse(json['created_by']?.toString() ?? '') ?? 0,
      graphic: graphic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': id,
      'material_name': material_name,
      'published_at': published_at?.toIso8601String(),
      'created_by': created_by,
      'graphic_id': graphic.id,
      'file_name': graphic.fileName,
      'file_path': graphic.filePath,
      'file_type': graphic.fileType,
      'asset_type': graphic.asset_type,
      'description': graphic.description,
    };
  }

  MaterialModal copyWith({
    int? id,
    String? material_name,
    DateTime? published_at,
    int? created_by,
    GraphicAsset? graphic,
  }) {
    return MaterialModal(
      id: id ?? this.id,
      material_name: material_name ?? this.material_name,
      published_at: published_at ?? this.published_at,
      created_by: created_by ?? this.created_by,
      graphic: graphic ?? this.graphic,
    );
  }

  @override
  String toString() {
    return 'MaterialModal{id: $id, material_name: $material_name, published_at: $published_at, created_by: $created_by, graphic: $graphic}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MaterialModal && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
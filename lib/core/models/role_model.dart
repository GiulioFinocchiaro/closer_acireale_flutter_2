import 'package:closer_acireale_flutter/core/models/permission_model.dart';

class RoleModel{
  final int id;
  final String name;
  final int level;
  final String color;
  final int? school_id;
  final List<PermissionModel> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.level,
    required this.color,
    required this.school_id,
    required this.permissions
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '')
          ?? 0,
      name: (json['name'] ?? '').toString(),
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '')
          ?? 0,
      color: (json['color'] ?? '#808080').toString(),
      school_id: json['school_id'] is int
          ? json['school_id']
          : int.tryParse(json['school_id']?.toString() ?? ''),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((p) => PermissionModel.fromJson(p))
          .toList()
          ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'color': color,
      'school_id': school_id,
      'permissions': permissions.map((p) => p.toJson()).toList(),
    };
  }

  RoleModel copyWith({
    int? id,
    String? name,
    int? level,
    String? color,
    int? school_id,
    List<PermissionModel>? permissions
  }) {
    return RoleModel(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
        color: color ?? this.color,
        school_id: school_id ?? this.school_id,
        permissions: permissions ?? this.permissions
    );
  }

  @override
  String toString() {
    return 'RoleModel{id: $id, name: $name, level: $level, color: $color, school_id: $school_id, permissions: $permissions}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
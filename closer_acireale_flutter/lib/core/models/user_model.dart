import 'package:closer_acireale_flutter/core/models/role_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final List<RoleModel> roles;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('JSON ${json.toString()}');
    print('JSON id ${json['id']}');
    return UserModel(
      id: json['id'] is int
        ? json['id']
        : int.tryParse(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List<dynamic>?)
          ?.map((role) => RoleModel.fromJson(role))
          .toList()
          ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'roles': roles.map((r) => r.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool hasRole(String role) {
    return roles.any((r) => r.name.toLowerCase() == role.toLowerCase());
  }

  bool get isAdmin {
    return roles.any((r) =>
    r.name.toLowerCase().contains('admin') ||
        r.name.toLowerCase().contains('amministratore')
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    List<RoleModel>? roles,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
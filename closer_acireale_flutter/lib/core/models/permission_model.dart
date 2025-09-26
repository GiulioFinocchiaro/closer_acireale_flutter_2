class PermissionModel {
  final int id;
  final String name;
  final String display_name;

  PermissionModel({
    required this.id,
    required this.name,
    required this.display_name
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] is int
        ? json['id']
        : int.tryParse(json['id']),
      name: json['name'] ?? '',
      display_name: json['display_name'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': display_name
    };
  }

  @override
  String toString() {
    return 'PermissionModel{id: $id, name: $name, display_name: $display_name}';
  }
}
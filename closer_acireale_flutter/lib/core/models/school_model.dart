class SchoolModel {
  final int id;
  final String school_name;
  final String list_name;
  final int active_campaigns_per_school;
  final int candidates_per_school;

  SchoolModel({
    required this.id,
    required this.school_name,
    required this.list_name,
    required this.active_campaigns_per_school,
    required this.candidates_per_school
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString()) ?? 0,

      school_name: json['school_name'] ?? '',
      list_name: json['list_name'] ?? '',
      active_campaigns_per_school: json["active_campaigns_per_school"] is int
          ? json["active_campaigns_per_school"]
          : int.tryParse(json["active_campaigns_per_school"].toString()) ?? 0,

      candidates_per_school: json["candidates_per_school"] is int
          ? json["candidates_per_school"]
          : int.tryParse(json["candidates_per_school"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': school_name,
      'list_name': list_name
    };
  }

  SchoolModel copyWith({
    int? id,
    String? school_name,
    String? list_name,
    int? active_campaigns_per_school,
    int? candidates_per_school
  }) {
    return SchoolModel(
      id: id ?? this.id,
      school_name: school_name ?? this.school_name,
      list_name: list_name ?? this.list_name,
      active_campaigns_per_school: active_campaigns_per_school ?? this.active_campaigns_per_school,
      candidates_per_school: candidates_per_school ?? this.candidates_per_school
    );
  }


  @override
  String toString() {
    return 'SchoolModel{id: $id, school_name: $school_name, list_name: $list_name, active_campaigns_per_school: $active_campaigns_per_school, candidates_per_school: $candidates_per_school}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
class Candidate {
  final int id;
  final String userName;
  final String? description;
  final String? classYear;
  final String? photo;
  final String? manifesto;
  final int? userId;
  final int? schoolId;
  final String? createdAt;

  Candidate({
    required this.id,
    required this.userName,
    this.description,
    this.classYear,
    this.photo,
    this.manifesto,
    this.userId,
    this.schoolId,
    this.createdAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      classYear: json['class_year'],
      photo: json['photo'],
      manifesto: json['manifesto'],
      userId: json['user_id'],
      schoolId: json['school_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_name': userName,
      'description': description,
    };

    if (classYear != null) data['class_year'] = classYear;
    if (photo != null) data['photo'] = photo;
    if (manifesto != null) data['manifesto'] = manifesto;
    if (userId != null) data['user_id'] = userId;
    if (schoolId != null) data['school_id'] = schoolId;
    if (createdAt != null) data['created_at'] = createdAt;

    return data;
  }
}
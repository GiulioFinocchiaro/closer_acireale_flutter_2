class GraphicAsset {
  final int id;
  final String fileName;
  final String filePath;
  final String asset_type; // 'document', 'video', 'audio', 'image'
  final String fileType;
  final String description;

  GraphicAsset({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.asset_type,
    required this.description,
  });

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(
      filePath.split('.').last.toLowerCase());
  
  bool get isPdf => filePath.toLowerCase().endsWith('.pdf');
  
  bool get isDocument => fileType == 'document';
  bool get isVideo => fileType == 'video';
  bool get isAudio => fileType == 'audio';

  String get fullUrl => 'https://www.closeracireale.it/cdn/$filePath';

  factory GraphicAsset.fromJson(Map<String, dynamic> json) {
    return GraphicAsset(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? json['name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? 'document',
      asset_type: json['asset_type'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'asset_type': asset_type,
      'description': description,
    };
  }
}
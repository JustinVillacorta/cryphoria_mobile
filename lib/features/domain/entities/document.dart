class Document {
  final String id;
  final String fileName;
  final String documentType;
  final String status;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Document({
    required this.id,
    required this.fileName,
    required this.documentType,
    required this.status,
    this.fileUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']?.toString() ?? '') 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'document_type': documentType,
      'status': status,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Document copyWith({
    String? id,
    String? fileName,
    String? documentType,
    String? status,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document &&
        other.id == id &&
        other.fileName == fileName &&
        other.documentType == documentType &&
        other.status == status &&
        other.fileUrl == fileUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fileName.hashCode ^
        documentType.hashCode ^
        status.hashCode ^
        fileUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Document(id: $id, fileName: $fileName, documentType: $documentType, status: $status, fileUrl: $fileUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
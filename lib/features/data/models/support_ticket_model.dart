import '../../domain/entities/support_ticket.dart';

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.id,
    required super.subject,
    required super.message,
    required super.category,
    required super.priority,
    required super.status,
    required super.attachments,
    required super.createdAt,
    super.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']?.toString() ?? '') 
          : null,
    );
  }

  factory SupportTicketModel.fromEntity(SupportTicket entity) {
    return SupportTicketModel(
      id: entity.id,
      subject: entity.subject,
      message: entity.message,
      category: entity.category,
      priority: entity.priority,
      status: entity.status,
      attachments: entity.attachments,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'category': category,
      'priority': priority,
      'status': status,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupportTicket toEntity() {
    return SupportTicket(
      id: id,
      subject: subject,
      message: message,
      category: category,
      priority: priority,
      status: status,
      attachments: attachments,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class SupportMessageModel extends SupportMessage {
  const SupportMessageModel({
    required super.id,
    required super.subject,
    required super.message,
    required super.category,
    required super.priority,
    required super.status,
    required super.attachments,
    required super.createdAt,
    super.updatedAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['message_id']?.toString() ?? json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']?.toString() ?? '') 
          : null,
    );
  }

  factory SupportMessageModel.fromEntity(SupportMessage entity) {
    return SupportMessageModel(
      id: entity.id,
      subject: entity.subject,
      message: entity.message,
      category: entity.category,
      priority: entity.priority,
      status: entity.status,
      attachments: entity.attachments,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'category': category,
      'priority': priority,
      'status': status,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupportMessage toEntity() {
    return SupportMessage(
      id: id,
      subject: subject,
      message: message,
      category: category,
      priority: priority,
      status: status,
      attachments: attachments,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
class SupportTicket {
  final String id;
  final String subject;
  final String message;
  final String category;
  final String priority;
  final String status;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.category,
    required this.priority,
    required this.status,
    required this.attachments,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
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

  SupportTicket copyWith({
    String? id,
    String? subject,
    String? message,
    String? category,
    String? priority,
    String? status,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupportTicket &&
        other.id == id &&
        other.subject == subject &&
        other.message == message &&
        other.category == category &&
        other.priority == priority &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        subject.hashCode ^
        message.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }
}

class SupportMessage {
  final String id;
  final String subject;
  final String message;
  final String category;
  final String priority;
  final String status;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupportMessage({
    required this.id,
    required this.subject,
    required this.message,
    required this.category,
    required this.priority,
    required this.status,
    required this.attachments,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupportMessage &&
        other.id == id &&
        other.subject == subject &&
        other.message == message &&
        other.category == category &&
        other.priority == priority &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        subject.hashCode ^
        message.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }
}

enum SupportCategory {
  technical,
  billing,
  account,
  general,
}

enum SupportPriority {
  low,
  medium,
  high,
  urgent,
}

enum SupportStatus {
  open,
  inProgress,
  resolved,
  closed,
}

extension SupportCategoryExtension on SupportCategory {
  String get value {
    switch (this) {
      case SupportCategory.technical:
        return 'technical';
      case SupportCategory.billing:
        return 'billing';
      case SupportCategory.account:
        return 'account';
      case SupportCategory.general:
        return 'general';
    }
  }

  String get displayName {
    switch (this) {
      case SupportCategory.technical:
        return 'Technical';
      case SupportCategory.billing:
        return 'Billing';
      case SupportCategory.account:
        return 'Account';
      case SupportCategory.general:
        return 'General';
    }
  }
}

extension SupportPriorityExtension on SupportPriority {
  String get value {
    switch (this) {
      case SupportPriority.low:
        return 'low';
      case SupportPriority.medium:
        return 'medium';
      case SupportPriority.high:
        return 'high';
      case SupportPriority.urgent:
        return 'urgent';
    }
  }

  String get displayName {
    switch (this) {
      case SupportPriority.low:
        return 'Low';
      case SupportPriority.medium:
        return 'Medium';
      case SupportPriority.high:
        return 'High';
      case SupportPriority.urgent:
        return 'Urgent';
    }
  }
}

extension SupportStatusExtension on SupportStatus {
  String get value {
    switch (this) {
      case SupportStatus.open:
        return 'open';
      case SupportStatus.inProgress:
        return 'in_progress';
      case SupportStatus.resolved:
        return 'resolved';
      case SupportStatus.closed:
        return 'closed';
    }
  }

  String get displayName {
    switch (this) {
      case SupportStatus.open:
        return 'Open';
      case SupportStatus.inProgress:
        return 'In Progress';
      case SupportStatus.resolved:
        return 'Resolved';
      case SupportStatus.closed:
        return 'Closed';
    }
  }
}
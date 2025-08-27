class UserSession {
  final String sid;
  final String deviceName;
  final String deviceId;
  final String ip;
  final String userAgent;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool approved;
  final DateTime? approvedAt;
  final DateTime? revokedAt;
  final bool isCurrent;

  UserSession({
    required this.sid,
    required this.deviceName,
    required this.deviceId,
    required this.ip,
    required this.userAgent,
    required this.createdAt,
    this.lastSeen,
    required this.approved,
    this.approvedAt,
    this.revokedAt,
    required this.isCurrent,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      sid: json['sid'] as String,
      deviceName: json['device_name'] as String,
      deviceId: json['device_id'] as String,
      ip: json['ip'] as String,
      userAgent: json['user_agent'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen'] as String) : null,
      approved: json['approved'] as bool,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'] as String) : null,
      revokedAt: json['revoked_at'] != null ? DateTime.parse(json['revoked_at'] as String) : null,
      isCurrent: json['is_current'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'device_name': deviceName,
      'device_id': deviceId,
      'ip': ip,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
      'approved': approved,
      'approved_at': approvedAt?.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'is_current': isCurrent,
    };
  }

  bool get isActive => revokedAt == null;
  bool get isLegacy => sid == 'legacy';
}

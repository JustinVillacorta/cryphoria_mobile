class AuthUser {
  final String userId;
  final String username;
  final String email;
  final String token;
  final String sessionId;
  final bool approved;
  final bool isActive;
  final DateTime tokenCreatedAt;

  AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
    required this.sessionId,
    required this.approved,
    required this.isActive,
    required this.tokenCreatedAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      sessionId: json['session_id'] as String,
      approved: json['approved'] as bool,
      isActive: json['is_active'] as bool,
      tokenCreatedAt: DateTime.parse(json['token_created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'token': token,
      'session_id': sessionId,
      'approved': approved,
      'is_active': isActive,
      'token_created_at': tokenCreatedAt.toIso8601String(),
    };
  }
}
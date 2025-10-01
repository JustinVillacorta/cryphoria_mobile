class AuthUser {
  final String userId;
  final String username;
  final String email;
  final String role;
  final String token;
  final bool approved;
  final bool isActive;

  AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.token,
    required this.approved,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Employee',
      token: json['token']?.toString() ?? '',
      approved: json['is_verified'] as bool? ?? json['approved'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'role': role,
      'token': token,
      'approved': approved,
      'is_active': isActive,
    };
  }
}
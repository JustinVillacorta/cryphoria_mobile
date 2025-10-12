class AuthUser {
  final String userId;
  final String firstName;
  final String? lastName;
  final String email;
  final String role;
  final String token;
  final bool approved;
  final bool isActive;

  AuthUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.token,
    required this.approved,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? json['email']?.toString() ?? '',
      lastName: json['last_name']?.toString(),
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
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
      'token': token,
      'approved': approved,
      'is_active': isActive,
    };
  }
}
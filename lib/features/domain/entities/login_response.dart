import 'auth_user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final AuthUser data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userField = json['user'];
    final sessionToken = json['session_token'];
    
    if (userField == null) {
      throw Exception('Login response user field is null');
    }
    
    if (userField is! Map<String, dynamic>) {
      throw Exception('Login response user field is not a Map: ${userField.runtimeType}');
    }
    
    if (sessionToken == null) {
      throw Exception('Login response session_token field is null');
    }
    
    // Add session_token to user data for AuthUser.fromJson
    final userData = Map<String, dynamic>.from(userField);
    userData['token'] = sessionToken;
    
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AuthUser.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

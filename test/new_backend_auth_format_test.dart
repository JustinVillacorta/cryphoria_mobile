import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';

void main() {
  group('New Backend Authentication Format Tests', () {
    test('LoginResponse.fromJson should parse new backend response format correctly', () {
      // Simulate the exact backend response format
      final backendResponse = {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': '60f0c8b8e4b0c8a9f8e9b9c9',
          'email': 'test@example.com',
          'first_name': 'John',
          'last_name': 'Doe',
          'username': 'test@example.com',
          'role': 'Employee',
          'is_verified': true
        },
        'session_token': 'abc123-session-token-xyz789'
      };

      final loginResponse = LoginResponse.fromJson(backendResponse);

      expect(loginResponse.success, true);
      expect(loginResponse.message, 'Login successful');
      expect(loginResponse.data.userId, '60f0c8b8e4b0c8a9f8e9b9c9');
      expect(loginResponse.data.email, 'test@example.com');
      expect(loginResponse.data.firstName, 'test@example.com');
      expect(loginResponse.data.role, 'Employee');
      expect(loginResponse.data.token, 'abc123-session-token-xyz789');
      expect(loginResponse.data.approved, true); // Should map from is_verified
    });

    test('AuthUser.fromJson should handle new backend user object format', () {
      final userJson = {
        'id': '60f0c8b8e4b0c8a9f8e9b9c9',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'username': 'test@example.com',
        'role': 'Manager',
        'is_verified': false,
        'token': 'session-token-123'
      };

      final authUser = AuthUser.fromJson(userJson);

      expect(authUser.userId, '60f0c8b8e4b0c8a9f8e9b9c9');
      expect(authUser.email, 'test@example.com');
      expect(authUser.firstName, 'test@example.com');
      expect(authUser.role, 'Manager');
      expect(authUser.token, 'session-token-123');
      expect(authUser.approved, false); // Should map from is_verified
      expect(authUser.isActive, true); // Should default to true
    });

    test('LoginResponse should handle missing user field', () {
      final invalidResponse = {
        'success': true,
        'message': 'Login successful',
        'session_token': 'abc123'
        // Missing 'user' field
      };

      expect(
        () => LoginResponse.fromJson(invalidResponse),
        throwsException,
      );
    });

    test('LoginResponse should handle missing session_token field', () {
      final invalidResponse = {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': '123',
          'email': 'test@example.com'
        }
        // Missing 'session_token' field
      };

      expect(
        () => LoginResponse.fromJson(invalidResponse),
        throwsException,
      );
    });
  });
}
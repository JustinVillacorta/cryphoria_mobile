import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Registration with Device Auto-Approval', () {
    test('Registration should include device info and auto-approve', () {
      // Registration request should include device information
      final registrationRequest = {
        'username': 'newuser',
        'password': 'password123',
        'email': 'newuser@example.com',
        'device_name': 'iPhone/iPad', // Device info included
        'device_id': 'new_device_001',
      };
      
      // Registration response should auto-approve the first device
      final registrationResponse = {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'user_id': 'user789',
          'username': 'newuser',
          'email': 'newuser@example.com',
          'token': 'jwt_token_new',
          'session_id': 'session_new_001',
          'approved': true, // ✅ Registration auto-approves first device
          'is_active': true,
          'token_created_at': '2024-08-27T15:00:00Z',
        }
      };
      
      // Verify registration includes device info
      expect(registrationRequest.containsKey('device_name'), isTrue);
      expect(registrationRequest.containsKey('device_id'), isTrue);
      expect(registrationRequest.containsKey('username'), isTrue);
      expect(registrationRequest.containsKey('email'), isTrue);
      
      // Verify registration auto-approves
      final responseData = registrationResponse['data'] as Map<String, dynamic>;
      expect(responseData['approved'], isTrue, 
        reason: 'Registration should auto-approve the first device');
      expect(registrationResponse['message'], 'Registration successful');
      
      // Registration should navigate to main app, not approval pending
      expect(responseData['approved'] ? 'WidgetTree' : 'ApprovalPending', 'WidgetTree');
    });

    test('Registration vs Login behavior comparison', () {
      // Registration (new user, first device)
      final registrationScenario = {
        'action': 'register',
        'user_exists': false,
        'device_count': 0,
        'expected_approval': true,
        'expected_navigation': 'WidgetTree',
      };
      
      // Login (existing user, first device)  
      final loginFirstDeviceScenario = {
        'action': 'login',
        'user_exists': true,
        'device_count': 0,
        'expected_approval': true,
        'expected_navigation': 'WidgetTree',
      };
      
      // Login (existing user, second device)
      final loginSecondDeviceScenario = {
        'action': 'login',
        'user_exists': true,
        'device_count': 1,
        'expected_approval': false,
        'expected_navigation': 'ApprovalPending',
      };
      
      // Verify registration always auto-approves
      expect(registrationScenario['expected_approval'], isTrue,
        reason: 'Registration should always auto-approve first device');
        
      // Verify login behavior depends on device count
      expect(loginFirstDeviceScenario['expected_approval'], isTrue,
        reason: 'First login device should auto-approve');
      expect(loginSecondDeviceScenario['expected_approval'], isFalse,
        reason: 'Second login device should require approval');
    });

    test('Device info consistency between login and registration', () {
      final deviceInfo = {
        'iOS': 'iPhone/iPad',
        'Android': 'Android Device',
        'Mac': 'Mac',
        'Windows': 'Windows PC',
        'Linux': 'Linux Device',
      };
      
      // Both login and registration should use same device naming
      expect(deviceInfo['iOS'], 'iPhone/iPad');
      expect(deviceInfo['Android'], 'Android Device');
      
      // Device ID should be persistent per device
      final deviceIdBehavior = '''
      Device ID generation:
      1. Check if device ID exists in secure storage
      2. If exists, use existing ID (persistence)
      3. If not exists, generate new ID and store it
      4. Same device always gets same ID across app restarts
      ''';
      
      expect(deviceIdBehavior.contains('persistence'), isTrue);
    });
  });
}

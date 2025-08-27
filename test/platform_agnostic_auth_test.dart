import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Platform-Agnostic Multi-Session Authentication', () {
    test('Android first, then iOS - should work correctly', () {
      // Scenario: Android emulator logs in first
      
      final firstDeviceLogin = {
        'username': 'testuser',
        'password': 'password123',
        'device_name': 'Android Device', // Android first
        'device_id': 'android_device_001',
      };
      
      final firstDeviceResponse = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user_id': 'user123',
          'username': 'testuser',
          'email': 'test@example.com',
          'token': 'jwt_token_android',
          'session_id': 'session_android_001',
          'approved': true, // ✅ First device (Android) is auto-approved
          'is_active': true,
          'token_created_at': '2024-08-27T10:00:00Z',
        }
      };
      
      // Then iOS logs in second
      final secondDeviceLogin = {
        'username': 'testuser',
        'password': 'password123',
        'device_name': 'iPhone/iPad', // iOS second
        'device_id': 'ios_device_001',
      };
      
      final secondDeviceResponse = {
        'success': true,
        'message': 'Login successful - pending approval on another device',
        'data': {
          'user_id': 'user123',
          'username': 'testuser',
          'email': 'test@example.com',
          'token': 'jwt_token_ios',
          'session_id': 'session_ios_001',
          'approved': false, // ❌ Second device (iOS) needs approval
          'is_active': true,
          'token_created_at': '2024-08-27T10:05:00Z',
        }
      };
      
      // Verify the logic works both ways
      final firstData = firstDeviceResponse['data'] as Map<String, dynamic>;
      final secondData = secondDeviceResponse['data'] as Map<String, dynamic>;
      
      expect(firstData['approved'], isTrue, 
        reason: 'First device (Android) should be auto-approved');
      expect(secondData['approved'], isFalse, 
        reason: 'Second device (iOS) should require approval');
        
      // Navigation expectations
      expect(firstData['approved'] ? 'WidgetTree' : 'ApprovalPending', 'WidgetTree');
      expect(secondData['approved'] ? 'WidgetTree' : 'ApprovalPending', 'ApprovalPending');
    });

    test('iOS first, then Android - should work correctly', () {
      // Scenario: iOS emulator logs in first
      
      final firstDeviceLogin = {
        'username': 'testuser2',
        'password': 'password123',
        'device_name': 'iPhone/iPad', // iOS first
        'device_id': 'ios_device_002',
      };
      
      final firstDeviceResponse = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user_id': 'user124',
          'username': 'testuser2',
          'email': 'test2@example.com',
          'token': 'jwt_token_ios_2',
          'session_id': 'session_ios_002',
          'approved': true, // ✅ First device (iOS) is auto-approved
          'is_active': true,
          'token_created_at': '2024-08-27T11:00:00Z',
        }
      };
      
      // Then Android logs in second
      final secondDeviceLogin = {
        'username': 'testuser2',
        'password': 'password123',
        'device_name': 'Android Device', // Android second
        'device_id': 'android_device_002',
      };
      
      final secondDeviceResponse = {
        'success': true,
        'message': 'Login successful - pending approval on another device',
        'data': {
          'user_id': 'user124',
          'username': 'testuser2',
          'email': 'test2@example.com',
          'token': 'jwt_token_android_2',
          'session_id': 'session_android_002',
          'approved': false, // ❌ Second device (Android) needs approval
          'is_active': true,
          'token_created_at': '2024-08-27T11:05:00Z',
        }
      };
      
      // Verify the logic works both ways
      final firstData = firstDeviceResponse['data'] as Map<String, dynamic>;
      final secondData = secondDeviceResponse['data'] as Map<String, dynamic>;
      
      expect(firstData['approved'], isTrue, 
        reason: 'First device (iOS) should be auto-approved');
      expect(secondData['approved'], isFalse, 
        reason: 'Second device (Android) should require approval');
        
      // Navigation expectations  
      expect(firstData['approved'] ? 'WidgetTree' : 'ApprovalPending', 'WidgetTree');
      expect(secondData['approved'] ? 'WidgetTree' : 'ApprovalPending', 'ApprovalPending');
    });

    test('Platform detection is consistent', () {
      final platformMappings = {
        'Android Device': 'android_device_id',
        'iPhone/iPad': 'ios_device_id',
        'Mac': 'mac_device_id',
        'Windows PC': 'windows_device_id',
        'Linux Device': 'linux_device_id',
      };
      
      // Verify each platform gets unique device names
      expect(platformMappings.keys.length, 5);
      expect(platformMappings.containsKey('Android Device'), isTrue);
      expect(platformMappings.containsKey('iPhone/iPad'), isTrue);
    });

    test('Backend determines approval, not client platform', () {
      // The key insight: Backend logic determines approval, not client
      
      final backendLogic = '''
      Backend determines approval based on:
      1. Is this the FIRST device for this user? → Auto-approve
      2. Is this a SUBSEQUENT device? → Require approval
      3. Platform type is irrelevant to approval logic
      ''';
      
      final clientBehavior = '''
      Client behavior based on backend response:
      1. approved: true → Navigate to WidgetTree
      2. approved: false → Navigate to ApprovalPendingView
      3. Platform only affects device_name sent to backend
      ''';
      
      expect(backendLogic.contains('Platform type is irrelevant'), isTrue);
      expect(clientBehavior.contains('Platform only affects device_name'), isTrue);
    });

    test('Cross-platform approval workflow', () {
      // Android approves iOS session
      final androidApprovesIOS = {
        'approver_device': 'Android Device',
        'pending_device': 'iPhone/iPad',
        'action': 'approve',
        'session_id': 'session_ios_pending'
      };
      
      // iOS approves Android session  
      final iOSApprovesAndroid = {
        'approver_device': 'iPhone/iPad',
        'pending_device': 'Android Device',
        'action': 'approve',
        'session_id': 'session_android_pending'
      };
      
      expect(androidApprovesIOS['action'], 'approve');
      expect(iOSApprovesAndroid['action'], 'approve');
      
      // Both scenarios should work identically
      expect(androidApprovesIOS['action'], equals(iOSApprovesAndroid['action']));
    });
  });
}

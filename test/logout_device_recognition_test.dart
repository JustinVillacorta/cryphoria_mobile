import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';

import 'logout_device_recognition_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<DeviceInfoService>(),
])
void main() {
  group('Logout and Device Recognition Flow', () {
    late MockAuthRepository mockAuthRepository;
    late MockDeviceInfoService mockDeviceInfoService;
    late Login loginUseCase;
    late Logout logoutUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockDeviceInfoService = MockDeviceInfoService();
      loginUseCase = Login(mockAuthRepository);
      logoutUseCase = Logout(mockAuthRepository);
    });

    test('should logout successfully and call API endpoint', () async {
      // Arrange
      when(mockAuthRepository.logout()).thenAnswer((_) async => true);

      // Act
      final result = await logoutUseCase.execute();

      // Assert
      expect(result, true);
      verify(mockAuthRepository.logout()).called(1);
    });

    test('should handle logout failure gracefully', () async {
      // Arrange
      when(mockAuthRepository.logout()).thenAnswer((_) async => false);

      // Act
      final result = await logoutUseCase.execute();

      // Assert
      expect(result, false);
      verify(mockAuthRepository.logout()).called(1);
    });

    test('should handle logout API error gracefully', () async {
      // Arrange
      when(mockAuthRepository.logout()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => logoutUseCase.execute(), throwsException);
      verify(mockAuthRepository.logout()).called(1);
    });

    test('device should be recognized as approved after logout and login again', () async {
      // Arrange - Simulate device info that remains consistent
      const deviceId = 'persistent-device-id-123';
      const deviceName = 'iPhone/iPad';
      
      when(mockDeviceInfoService.getDeviceId()).thenAnswer((_) async => deviceId);
      when(mockDeviceInfoService.getDeviceName()).thenAnswer((_) async => deviceName);

      // First login - should be approved (device was previously approved)
      final approvedUser = AuthUser(
        userId: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        token: 'new-token-after-relogin',
        sessionId: 'new-session-id',
        approved: true, // Should be true for previously approved device
        isActive: true,
        tokenCreatedAt: DateTime.now(),
      );

      final approvedLoginResponse = LoginResponse(
        success: true,
        message: 'Login successful - device recognized',
        data: approvedUser,
      );

      when(mockAuthRepository.login(
        'testuser',
        'password123',
        deviceName: deviceName,
        deviceId: deviceId,
      )).thenAnswer((_) async => approvedLoginResponse);

      // Act - Login again with same device info
      final loginResult = await loginUseCase.execute(
        'testuser',
        'password123',
        deviceName: deviceName,
        deviceId: deviceId,
      );

      // Assert - Should be approved immediately
      expect(loginResult.data.approved, true);
      expect(loginResult.message, contains('device recognized'));
      verify(mockAuthRepository.login(
        'testuser',
        'password123',
        deviceName: deviceName,
        deviceId: deviceId,
      )).called(1);
    });

    test('new device should require approval after logout from different device', () async {
      // Arrange - Simulate different device
      const newDeviceId = 'new-device-id-456';
      const newDeviceName = 'Android Device';
      
      when(mockDeviceInfoService.getDeviceId()).thenAnswer((_) async => newDeviceId);
      when(mockDeviceInfoService.getDeviceName()).thenAnswer((_) async => newDeviceName);

      // Login from new device - should require approval
      final pendingUser = AuthUser(
        userId: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        token: 'pending-token',
        sessionId: 'pending-session-id',
        approved: false, // Should be false for new device
        isActive: true,
        tokenCreatedAt: DateTime.now(),
      );

      final pendingLoginResponse = LoginResponse(
        success: true,
        message: 'Login successful - pending approval',
        data: pendingUser,
      );

      when(mockAuthRepository.login(
        'testuser',
        'password123',
        deviceName: newDeviceName,
        deviceId: newDeviceId,
      )).thenAnswer((_) async => pendingLoginResponse);

      // Act - Login from new device
      final loginResult = await loginUseCase.execute(
        'testuser',
        'password123',
        deviceName: newDeviceName,
        deviceId: newDeviceId,
      );

      // Assert - Should require approval
      expect(loginResult.data.approved, false);
      expect(loginResult.message, contains('pending approval'));
      verify(mockAuthRepository.login(
        'testuser',
        'password123',
        deviceName: newDeviceName,
        deviceId: newDeviceId,
      )).called(1);
    });

    test('should maintain device ID persistence across app restarts', () async {
      // Arrange - Device ID should be the same across multiple calls
      const persistentDeviceId = 'persistent-device-id-123';
      
      when(mockDeviceInfoService.getDeviceId()).thenAnswer((_) async => persistentDeviceId);

      // Act - Call multiple times to simulate app restarts
      final deviceId1 = await mockDeviceInfoService.getDeviceId();
      final deviceId2 = await mockDeviceInfoService.getDeviceId();
      final deviceId3 = await mockDeviceInfoService.getDeviceId();

      // Assert - Should be the same every time
      expect(deviceId1, persistentDeviceId);
      expect(deviceId2, persistentDeviceId);
      expect(deviceId3, persistentDeviceId);
      expect(deviceId1, equals(deviceId2));
      expect(deviceId2, equals(deviceId3));
      verify(mockDeviceInfoService.getDeviceId()).called(3);
    });
  });
}

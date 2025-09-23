import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:cryphoria_mobile/features/presentation/manager/SessionManagement/session_management_controller.dart';
import 'package:cryphoria_mobile/features/presentation/manager/SessionManagement/session_management_viewmodel.dart';

import '../../../domain/usecases/session_usecases_test.mocks.dart';

void main() {
  group('Session Management Integration', () {
    late SessionManagementController controller;
    late SessionManagementViewModel viewModel;
    late MockGetSessions mockGetSessions;
    late MockApproveSession mockApproveSession;
    late MockRevokeSession mockRevokeSession;
    late MockRevokeOtherSessions mockRevokeOtherSessions;

    setUp(() {
      mockGetSessions = MockGetSessions();
      mockApproveSession = MockApproveSession();
      mockRevokeSession = MockRevokeSession();
      mockRevokeOtherSessions = MockRevokeOtherSessions();
      viewModel = SessionManagementViewModel();
      
      controller = SessionManagementController(
        getSessions: mockGetSessions,
        approveSession: mockApproveSession,
        revokeSession: mockRevokeSession,
        revokeOtherSessions: mockRevokeOtherSessions,
        viewModel: viewModel,
      );
    });

    test('should load sessions successfully', () async {
      // Arrange
      final mockSessions = [
        UserSession(
          sid: 'session1',
          deviceName: 'iPhone/iPad',
          deviceId: 'device1',
          ip: '192.168.1.1',
          userAgent: 'iOS App',
          createdAt: DateTime.now(),
          approved: true,
          isCurrent: true,
        ),
        UserSession(
          sid: 'session2',
          deviceName: 'Android Device',
          deviceId: 'device2',
          ip: '192.168.1.2',
          userAgent: 'Android App',
          createdAt: DateTime.now(),
          approved: false,
          isCurrent: false,
        ),
      ];

      when(mockGetSessions.execute()).thenAnswer((_) async => mockSessions);

      // Act
      await controller.loadSessions();

      // Assert
      expect(viewModel.sessions, equals(mockSessions));
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockGetSessions.execute()).called(1);
    });

    test('should approve session successfully', () async {
      // Arrange
      const sessionId = 'session2';
      when(mockApproveSession.execute(sessionId)).thenAnswer((_) async => true);

      // Set up initial session
      final session = UserSession(
        sid: sessionId,
        deviceName: 'Android Device',
        deviceId: 'device2',
        ip: '192.168.1.2',
        userAgent: 'Android App',
        createdAt: DateTime.now(),
        approved: false,
        isCurrent: false,
      );
      viewModel.setSessions([session]);

      // Act
      await controller.approveSessionById(sessionId);

      // Assert
      verify(mockApproveSession.execute(sessionId)).called(1);
      expect(viewModel.sessions.first.approved, true);
    });

    test('should revoke session successfully', () async {
      // Arrange
      const sessionId = 'session2';
      when(mockRevokeSession.execute(sessionId)).thenAnswer((_) async => true);

      // Set up initial session
      final session = UserSession(
        sid: sessionId,
        deviceName: 'Android Device',
        deviceId: 'device2',
        ip: '192.168.1.2',
        userAgent: 'Android App',
        createdAt: DateTime.now(),
        approved: true,
        isCurrent: false,
      );
      viewModel.setSessions([session]);

      // Act
      await controller.revokeSessionById(sessionId);

      // Assert
      verify(mockRevokeSession.execute(sessionId)).called(1);
      expect(viewModel.sessions, isEmpty);
    });

    test('should revoke other sessions successfully', () async {
      // Arrange
      when(mockRevokeOtherSessions.execute()).thenAnswer((_) async => true);
      when(mockGetSessions.execute()).thenAnswer((_) async => [
        UserSession(
          sid: 'session1',
          deviceName: 'iPhone/iPad',
          deviceId: 'device1',
          ip: '192.168.1.1',
          userAgent: 'iOS App',
          createdAt: DateTime.now(),
          approved: true,
          isCurrent: true,
        ),
      ]);

      // Act
      await controller.revokeAllOtherSessions();

      // Assert
      verify(mockRevokeOtherSessions.execute()).called(1);
      verify(mockGetSessions.execute()).called(1);
    });

    test('should handle approval failure', () async {
      // Arrange
      const sessionId = 'session2';
      when(mockApproveSession.execute(sessionId)).thenAnswer((_) async => false);

      // Set up initial session
      final session = UserSession(
        sid: sessionId,
        deviceName: 'Android Device',
        deviceId: 'device2',
        ip: '192.168.1.2',
        userAgent: 'Android App',
        createdAt: DateTime.now(),
        approved: false,
        isCurrent: false,
      );
      viewModel.setSessions([session]);

      // Act
      await controller.approveSessionById(sessionId);

      // Assert
      verify(mockApproveSession.execute(sessionId)).called(1);
      expect(viewModel.sessions.first.approved, false); // Should remain unchanged
    });

    test('should handle errors during session loading', () async {
      // Arrange
      when(mockGetSessions.execute()).thenThrow(Exception('Network error'));

      // Act
      await controller.loadSessions();

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.error, contains('Failed to load sessions'));
      verify(mockGetSessions.execute()).called(1);
    });

    test('should categorize sessions correctly by device', () {
      // Arrange
      final sessions = [
        UserSession(
          sid: 'session1',
          deviceName: 'iPhone/iPad',
          deviceId: 'device1',
          ip: '192.168.1.1',
          userAgent: 'iOS App',
          createdAt: DateTime.now(),
          approved: true,
          isCurrent: true,
        ),
        UserSession(
          sid: 'session2',
          deviceName: 'Android Device',
          deviceId: 'device2',
          ip: '192.168.1.2',
          userAgent: 'Android App',
          createdAt: DateTime.now(),
          approved: false,
          isCurrent: false,
        ),
        UserSession(
          sid: 'session3',
          deviceName: 'Mac',
          deviceId: 'device3',
          ip: '192.168.1.3',
          userAgent: 'macOS App',
          createdAt: DateTime.now(),
          approved: true,
          isCurrent: false,
        ),
      ];

      // Act
      viewModel.setSessions(sessions);

      // Assert
      final currentDeviceId = 'device1';
      final currentSessions = viewModel.sessions.where((s) => s.deviceId == currentDeviceId).toList();
      final otherSessions = viewModel.sessions.where((s) => s.deviceId != currentDeviceId).toList();
      final pendingSessions = otherSessions.where((s) => !s.approved).toList();
      final activeSessions = otherSessions.where((s) => s.approved).toList();

      expect(currentSessions.length, 1);
      expect(otherSessions.length, 2);
      expect(pendingSessions.length, 1);
      expect(activeSessions.length, 1);
    });
  });
}

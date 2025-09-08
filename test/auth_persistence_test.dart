import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_persistence_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('Authentication Persistence Tests', () {
    late AuthLocalDataSourceImpl authLocalDataSource;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      authLocalDataSource = AuthLocalDataSourceImpl(secureStorage: mockSecureStorage);
    });

    test('should persist auth user across app restarts', () async {
      // Arrange
      final authUser = AuthUser(
        userId: 'test-id',
        username: 'testuser',
        email: 'test@example.com',
        role: 'Employee',
        token: 'test-token',
        sessionId: 'test-session',
        approved: true,
        isActive: true,
        tokenCreatedAt: DateTime.now(),
      );

      final userJson = '{"user_id":"test-id","username":"testuser","email":"test@example.com","role":"Employee","token":"test-token","session_id":"test-session","approved":true,"is_active":true,"token_created_at":"${authUser.tokenCreatedAt.toIso8601String()}"}';

      // Mock storage write
      when(mockSecureStorage.write(key: 'auth_user', value: userJson))
          .thenAnswer((_) async {});

      // Mock storage read
      when(mockSecureStorage.read(key: 'auth_user'))
          .thenAnswer((_) async => userJson);

      // Act
      await authLocalDataSource.cacheAuthUser(authUser);
      final retrievedUser = await authLocalDataSource.getAuthUser();

      // Assert
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.username, equals('testuser'));
      expect(retrievedUser.token, equals('test-token'));
      expect(retrievedUser.approved, equals(true));
      
      verify(mockSecureStorage.write(key: 'auth_user', value: userJson)).called(1);
      verify(mockSecureStorage.read(key: 'auth_user')).called(1);
    });

    test('should return null when no auth data is stored', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'auth_user'))
          .thenAnswer((_) async => null);

      // Act
      final retrievedUser = await authLocalDataSource.getAuthUser();

      // Assert
      expect(retrievedUser, isNull);
      verify(mockSecureStorage.read(key: 'auth_user')).called(1);
    });

    test('should clear corrupted auth data', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'auth_user'))
          .thenAnswer((_) async => 'invalid-json');
      when(mockSecureStorage.delete(key: 'auth_user'))
          .thenAnswer((_) async {});
      when(mockSecureStorage.delete(key: 'auth_token'))
          .thenAnswer((_) async {});

      // Act
      final retrievedUser = await authLocalDataSource.getAuthUser();

      // Assert
      expect(retrievedUser, isNull);
      verify(mockSecureStorage.delete(key: 'auth_user')).called(1);
      verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
    });

    test('should properly clear all auth data', () async {
      // Arrange
      when(mockSecureStorage.delete(key: 'auth_user'))
          .thenAnswer((_) async {});
      when(mockSecureStorage.delete(key: 'auth_token'))
          .thenAnswer((_) async {});

      // Act
      await authLocalDataSource.clearAuthData();

      // Assert
      verify(mockSecureStorage.delete(key: 'auth_user')).called(1);
      verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
    });
  });
}

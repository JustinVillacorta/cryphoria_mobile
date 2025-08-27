import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cryphoria_mobile/core/network/device_info_interceptor.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';

import 'device_info_interceptor_test.mocks.dart';

@GenerateMocks([DeviceInfoService])
void main() {
  group('DeviceInfoInterceptor', () {
    late MockDeviceInfoService mockDeviceInfoService;
    late DeviceInfoInterceptor interceptor;

    setUp(() {
      mockDeviceInfoService = MockDeviceInfoService();
      interceptor = DeviceInfoInterceptor(deviceInfoService: mockDeviceInfoService);
    });

    test('should add device headers to all requests', () async {
      // Arrange
      when(mockDeviceInfoService.getDeviceName()).thenAnswer((_) async => 'iPhone/iPad');
      when(mockDeviceInfoService.getDeviceId()).thenAnswer((_) async => 'test-device-id-123');

      final options = RequestOptions(path: '/api/test');
      final handler = MockRequestInterceptorHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Wait a bit for async operations to complete
      await Future.delayed(Duration(milliseconds: 10));

      // Assert
      expect(options.headers['X-Device-Name'], equals('iPhone/iPad'));
      expect(options.headers['X-Device-ID'], equals('test-device-id-123'));
      verify(handler.next(options)).called(1);
    });

    test('should handle device info service errors gracefully', () async {
      // Arrange
      when(mockDeviceInfoService.getDeviceName()).thenThrow(Exception('Device name error'));
      when(mockDeviceInfoService.getDeviceId()).thenThrow(Exception('Device ID error'));

      final options = RequestOptions(path: '/api/test');
      final handler = MockRequestInterceptorHandler();

      // Act - should not throw
      interceptor.onRequest(options, handler);

      // Wait a bit for async operations to complete
      await Future.delayed(Duration(milliseconds: 10));

      // Assert - should still call handler.next even on error
      verify(handler.next(options)).called(1);
      // Headers should not be set if there's an error
      expect(options.headers.containsKey('X-Device-Name'), isFalse);
      expect(options.headers.containsKey('X-Device-ID'), isFalse);
    });
  });
}

// Mock class for RequestInterceptorHandler
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {
  @override
  void next(RequestOptions options) {
    super.noSuchMethod(Invocation.method(#next, [options]));
  }
}

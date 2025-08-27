import 'package:dio/dio.dart';
import '../../features/data/services/device_info_service.dart';

class DeviceInfoInterceptor extends Interceptor {
  final DeviceInfoService deviceInfoService;

  DeviceInfoInterceptor({required this.deviceInfoService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _addDeviceHeaders(options).then((_) {
      handler.next(options);
    }).catchError((error) {
      print('DeviceInfoInterceptor: Error adding device headers: $error');
      handler.next(options);
    });
  }

  Future<void> _addDeviceHeaders(RequestOptions options) async {
    try {
      // Add device info headers to all requests
      final deviceName = await deviceInfoService.getDeviceName();
      final deviceId = await deviceInfoService.getDeviceId();
      
      options.headers['X-Device-Name'] = deviceName;
      options.headers['X-Device-ID'] = deviceId;
      
      print('DeviceInfoInterceptor: Added headers - Device-Name: $deviceName, Device-ID: $deviceId');
    } catch (e) {
      print('DeviceInfoInterceptor: Error adding device headers: $e');
      rethrow;
    }
  }
}

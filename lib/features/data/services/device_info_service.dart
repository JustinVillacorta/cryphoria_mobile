import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class DeviceInfoService {
  Future<String> getDeviceName();
  Future<String> getDeviceId();
}

class DeviceInfoServiceImpl implements DeviceInfoService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _deviceIdKey = 'device_id';

  @override
  Future<String> getDeviceName() async {
    // Generate a default device name based on platform
    if (Platform.isIOS) {
      return 'iPhone/iPad';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isMacOS) {
      return 'Mac';
    } else if (Platform.isWindows) {
      return 'Windows PC';
    } else if (Platform.isLinux) {
      return 'Linux Device';
    } else {
      return 'Unknown Device';
    }
  }

  @override
  Future<String> getDeviceId() async {
    // Check if we already have a device ID stored
    String? existingId = await _storage.read(key: _deviceIdKey);
    
    if (existingId != null && existingId.isNotEmpty) {
      print('DeviceInfoService: Using existing device ID: $existingId');
      return existingId;
    }
    
    // Generate a new device ID and store it
    String newId = _generateDeviceId();
    await _storage.write(key: _deviceIdKey, value: newId);
    print('DeviceInfoService: Generated NEW device ID: $newId');
    return newId;
  }

  String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to cache device approval status locally
/// This helps maintain approval state even if backend doesn't persist it
class DeviceApprovalCache {
  static const _approvedDevicesKey = 'approved_devices';
  final FlutterSecureStorage _storage;

  DeviceApprovalCache({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Mark a device as approved for a specific user
  Future<void> markDeviceApproved(String username, String deviceId) async {
    final approvedDevices = await getApprovedDevices();
    final key = '${username}_$deviceId';
    
    if (!approvedDevices.contains(key)) {
      approvedDevices.add(key);
      await _saveApprovedDevices(approvedDevices);
      print('DeviceApprovalCache: Marked device approved - $key');
    }
  }

  /// Check if a device is approved for a specific user
  Future<bool> isDeviceApproved(String username, String deviceId) async {
    final approvedDevices = await getApprovedDevices();
    final key = '${username}_$deviceId';
    final isApproved = approvedDevices.contains(key);
    print('DeviceApprovalCache: Device approval check - $key: $isApproved');
    return isApproved;
  }

  /// Remove device approval (used during logout if needed)
  Future<void> removeDeviceApproval(String username, String deviceId) async {
    final approvedDevices = await getApprovedDevices();
    final key = '${username}_$deviceId';
    
    if (approvedDevices.remove(key)) {
      await _saveApprovedDevices(approvedDevices);
      print('DeviceApprovalCache: Removed device approval - $key');
    }
  }

  /// Get all approved devices
  Future<List<String>> getApprovedDevices() async {
    final approvedString = await _storage.read(key: _approvedDevicesKey);
    if (approvedString == null || approvedString.isEmpty) {
      return [];
    }
    return approvedString.split(',').where((item) => item.isNotEmpty).toList();
  }

  /// Clear all device approvals (for complete logout/reset)
  Future<void> clearAllApprovals() async {
    await _storage.delete(key: _approvedDevicesKey);
    print('DeviceApprovalCache: Cleared all device approvals');
  }

  /// Save approved devices list
  Future<void> _saveApprovedDevices(List<String> devices) async {
    final devicesString = devices.join(',');
    await _storage.write(key: _approvedDevicesKey, value: devicesString);
  }
}

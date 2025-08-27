import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'package:cryphoria_mobile/features/data/services/device_approval_cache.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final Login loginUseCase;
  final DeviceInfoService deviceInfoService;
  final DeviceApprovalCache deviceApprovalCache;

  AuthUser? _authUser;
  AuthUser? get authUser => _authUser;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginViewModel({
    required this.loginUseCase,
    required this.deviceInfoService,
    required this.deviceApprovalCache,
  });

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get device information
      final deviceName = await deviceInfoService.getDeviceName();
      final deviceId = await deviceInfoService.getDeviceId();

      // Check if device was previously approved
      final wasApproved = await deviceApprovalCache.isDeviceApproved(username, deviceId);
      print('LoginViewModel: Device previously approved: $wasApproved');

      _loginResponse = await loginUseCase.execute(
        username, 
        password, 
        deviceName: deviceName,
        deviceId: deviceId,
      );
      
      _authUser = _loginResponse!.data;

      // If login is successful and device is approved, cache the approval
      if (_authUser!.approved) {
        await deviceApprovalCache.markDeviceApproved(username, deviceId);
        print('LoginViewModel: Device approved - cached approval status');
      } else if (wasApproved) {
        // Device was previously approved but backend says it's not
        // This indicates a backend issue - log it
        print('LoginViewModel: WARNING - Device was previously approved locally but backend requires approval again');
      }

      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Login failed: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isApprovalPending => _loginResponse?.data.approved == false;
  
  String get loginMessage => _loginResponse?.message ?? '';
}

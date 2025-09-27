import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'package:cryphoria_mobile/features/data/services/device_approval_cache.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final Login loginUseCase;
  final DeviceInfoService deviceInfoService;
  final DeviceApprovalCache deviceApprovalCache;
  final AuthLocalDataSource authLocalDataSource;

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
    required this.authLocalDataSource,
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

      // If login is successful and device is approved, cache the approval and verify persistence
      if (_authUser!.approved) {
        await deviceApprovalCache.markDeviceApproved(username, deviceId);
        print('LoginViewModel: Device approved - cached approval status');
        
        // CRITICAL: Verify authentication was properly persisted
        await _verifyAuthenticationPersistence();
      } else if (wasApproved) {
        // Device was previously approved but backend says it's not
        // This indicates the user logged out and logged back in on the same device
        print('LoginViewModel: WARNING - Device was previously approved locally but backend requires approval again');
        print('LoginViewModel: This is the same device that was previously the main device');
        
        // Update the error message to be more informative
        _error = 'This device was previously approved. The backend now requires re-approval for security reasons.';
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

  Future<void> _verifyAuthenticationPersistence() async {
    try {
      print('🔍 LoginViewModel: Verifying authentication persistence...');
      
      // Wait a moment for storage operations to complete
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Try to retrieve the saved authentication data
      final savedUser = await authLocalDataSource.getAuthUser();
      
      if (savedUser == null) {
        throw Exception('No authentication data found after login');
      }
      
      if (savedUser.token != _authUser?.token) {
        throw Exception('Saved token does not match current token');
      }
      
      if (savedUser.username != _authUser?.username) {
        throw Exception('Saved username does not match current username');
      }
      
      print('✅ LoginViewModel: Authentication persistence verified successfully');
      print('  - Username: ${savedUser.username}');
      print('  - Token length: ${savedUser.token.length}');
      print('  - Approved: ${savedUser.approved}');
      
    } catch (e) {
      print('🔥 LoginViewModel: Persistence verification failed: $e');
      
      // Attempt to re-save the authentication data
      try {
        print('🔄 LoginViewModel: Attempting to re-save authentication data...');
        await authLocalDataSource.cacheAuthUser(_authUser!);
        
        // Verify again
        await Future.delayed(const Duration(milliseconds: 100));
        final retrySavedUser = await authLocalDataSource.getAuthUser();
        
        if (retrySavedUser != null && retrySavedUser.token == _authUser?.token) {
          print('✅ LoginViewModel: Re-save successful');
        } else {
          throw Exception('Re-save verification failed');
        }
        
      } catch (retryError) {
        print('🔥 LoginViewModel: Re-save failed: $retryError');
        _error = 'Warning: Login successful but authentication may not persist across app restarts. Please contact support if you experience issues.';
      }
    }
  }

  bool get isApprovalPending => _loginResponse?.data.approved == false;
  
  String get loginMessage => _loginResponse?.message ?? '';
}

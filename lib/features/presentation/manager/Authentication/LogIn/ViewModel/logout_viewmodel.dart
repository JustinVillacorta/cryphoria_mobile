import 'package:flutter/foundation.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_force_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_check_usecase.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';

class LogoutViewModel extends ChangeNotifier {
  final Logout logoutUseCase; // Regular logout
  final LogoutForce logoutForceUseCase; // Force logout
  final LogoutCheck logoutCheckUseCase;
  final AuthLocalDataSource authLocalDataSource;

  LogoutViewModel({
    required this.logoutUseCase,
    required this.logoutForceUseCase,
    required this.logoutCheckUseCase,
    required this.authLocalDataSource,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _message;
  String? get message => _message;

  // Transfer check result
  Map<String, dynamic>? _transferCheckResult;
  Map<String, dynamic>? get transferCheckResult => _transferCheckResult;

  bool get needsTransfer => _transferCheckResult?['needs_transfer'] == true;
  bool get canLogout => _transferCheckResult?['can_logout'] == true;

  /// Check if logout is safe (no main device transfer needed)
  Future<bool> checkLogoutSafety() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transferCheckResult = await logoutCheckUseCase.execute();
      _error = null;
      
      return canLogout;
    } on ServerException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Logout check failed: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Smart logout - tries regular logout first, falls back to transfer check if needed
  Future<bool> smartLogout() async {
    try {
      _isLoading = true;
      _error = null;
      _message = null;
      notifyListeners();

      // First try regular logout
      final success = await logoutUseCase.execute();
      
      if (success) {
        // Clear local authentication data
        await authLocalDataSource.clearAuthData();
        _message = "Logout successful";
        return true;
      } else {
        // If regular logout fails, check if transfer is needed (if backend supports it)
        try {
          _transferCheckResult = await logoutCheckUseCase.execute();
          _error = "Cannot logout: ${_transferCheckResult?['message'] ?? 'Transfer may be required'}";
          return false;
        } catch (e) {
          // If transfer check is not implemented, fall back to force logout
          print('Transfer check not available, using force logout: $e');
          return await forceLogout();
        }
      }
    } on ServerException catch (e) {
      // If logout fails due to unimplemented endpoints, try force logout
      if (e.message.contains('404') || e.message.contains('Not Found')) {
        print('Logout endpoint not found, trying force logout: ${e.message}');
        return await forceLogout();
      }
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Logout failed: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force logout without transfer check
  Future<bool> forceLogout() async {
    try {
      _isLoading = true;
      _error = null;
      _message = null;
      notifyListeners();

      // Call backend force logout
      final success = await logoutForceUseCase.execute();
      
      if (success) {
        // Clear local authentication data
        await authLocalDataSource.clearAuthData();
        _message = "Logout successful";
        return true;
      } else {
        _error = "Logout failed";
        return false;
      }
    } on ServerException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Logout failed: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _message = null;
    notifyListeners();
  }
}
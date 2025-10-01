import 'package:flutter/foundation.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';

class LogoutViewModel extends ChangeNotifier {
  final Logout logoutUseCase;
  final AuthLocalDataSource authLocalDataSource;

  LogoutViewModel({
    required this.logoutUseCase,
    required this.authLocalDataSource,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _message;
  String? get message => _message;

  /// Perform logout
  Future<bool> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await logoutUseCase.execute();
      
      if (success) {
        // Clear local auth data
        await authLocalDataSource.clearAuthData();
        _message = 'Logout successful';
        _error = null;
      } else {
        _error = 'Logout failed';
      }
      
      return success;
    } on ServerException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred during logout';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

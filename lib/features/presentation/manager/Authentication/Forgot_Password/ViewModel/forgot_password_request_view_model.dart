import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/request_password_reset_use_case.dart';
import 'package:flutter/foundation.dart';

class ForgotPasswordRequestViewModel extends ChangeNotifier {
  final RequestPasswordReset requestPasswordResetUseCase;

  bool _isRequestSent = false;
  bool get isRequestSent => _isRequestSent;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ForgotPasswordRequestViewModel({
    required this.requestPasswordResetUseCase,
  });

  Future<void> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await requestPasswordResetUseCase.execute(email);
      _isRequestSent = true;
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
      _isRequestSent = false;
    } catch (e) {
      _error = "Failed to send reset code: ${e.toString()}";
      _isRequestSent = false;
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

import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/reset_password_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/resend_password_reset_use_case.dart';
import 'package:flutter/foundation.dart';

class ForgotPasswordConfirmViewModel extends ChangeNotifier {
  final ResetPassword resetPasswordUseCase;
  final ResendPasswordReset resendPasswordResetUseCase;

  bool _isPasswordReset = false;
  bool get isPasswordReset => _isPasswordReset;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ForgotPasswordConfirmViewModel({
    required this.resetPasswordUseCase,
    required this.resendPasswordResetUseCase,
  });

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await resetPasswordUseCase.execute(email, otp, newPassword);
      _isPasswordReset = true;
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
      _isPasswordReset = false;
    } catch (e) {
      _error = "Password reset failed: ${e.toString()}";
      _isPasswordReset = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendResetCode(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await resendPasswordResetUseCase.execute(email);
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Failed to resend reset code: ${e.toString()}";
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

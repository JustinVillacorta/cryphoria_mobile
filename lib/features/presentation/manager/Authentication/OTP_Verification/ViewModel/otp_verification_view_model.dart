import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/OTP_Verification/verify_otp_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/OTP_Verification/resend_otp_use_case.dart';
import 'package:flutter/foundation.dart';

class OTPVerificationViewModel extends ChangeNotifier {
  final VerifyOTP verifyOTPUseCase;
  final ResendOTP resendOTPUseCase;

  bool _isVerified = false;
  bool get isVerified => _isVerified;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OTPVerificationViewModel({
    required this.verifyOTPUseCase,
    required this.resendOTPUseCase,
  });

  Future<void> verifyOTP(String email, String code) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await verifyOTPUseCase.execute(email, code);
      _isVerified = result;
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
      _isVerified = false;
    } catch (e) {
      _error = "OTP verification failed: ${e.toString()}";
      _isVerified = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await resendOTPUseCase.execute(email);
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Failed to resend OTP: ${e.toString()}";
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

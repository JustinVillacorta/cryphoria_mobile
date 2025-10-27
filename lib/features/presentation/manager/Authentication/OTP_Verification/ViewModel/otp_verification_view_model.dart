import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/OTP_Verification/verify_otp_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/OTP_Verification/resend_otp_use_case.dart';
import 'otp_verification_state.dart';

class OTPVerificationViewModel extends StateNotifier<OTPVerificationState> {
  final VerifyOTP verifyOTPUseCase;
  final ResendOTP resendOTPUseCase;

  OTPVerificationViewModel({
    required this.verifyOTPUseCase,
    required this.resendOTPUseCase,
  }) : super(OTPVerificationState.initial());

  Future<void> verifyOTP(String email, String code) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      final result = await verifyOTPUseCase.execute(email, code);
      
      state = state.copyWith(
        isLoading: false,
        isVerified: result,
        error: () => null,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
        isVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => "OTP verification failed: ${e.toString()}",
        isVerified: false,
      );
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      await resendOTPUseCase.execute(email);
      
      state = state.copyWith(
        isLoading: false,
        error: () => null,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to resend OTP: ${e.toString()}",
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

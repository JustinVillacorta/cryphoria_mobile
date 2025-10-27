import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/reset_password_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/resend_password_reset_use_case.dart';
import 'forgot_password_confirm_state.dart';

class ForgotPasswordConfirmViewModel extends StateNotifier<ForgotPasswordConfirmState> {
  final ResetPassword resetPasswordUseCase;
  final ResendPasswordReset resendPasswordResetUseCase;

  ForgotPasswordConfirmViewModel({
    required this.resetPasswordUseCase,
    required this.resendPasswordResetUseCase,
  }) : super(ForgotPasswordConfirmState.initial());

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      await resetPasswordUseCase.execute(email, otp, newPassword);
      
      state = state.copyWith(
        isLoading: false,
        isPasswordReset: true,
        error: () => null,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
        isPasswordReset: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => "Password reset failed: ${e.toString()}",
        isPasswordReset: false,
      );
    }
  }

  Future<void> resendResetCode(String email) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      await resendPasswordResetUseCase.execute(email);
      
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
        error: () => "Failed to resend reset code: ${e.toString()}",
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

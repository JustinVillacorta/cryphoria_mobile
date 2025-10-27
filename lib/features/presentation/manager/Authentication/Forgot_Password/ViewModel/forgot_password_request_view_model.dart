import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Forgot_Password/request_password_reset_use_case.dart';
import 'forgot_password_request_state.dart';

class ForgotPasswordRequestViewModel extends StateNotifier<ForgotPasswordRequestState> {
  final RequestPasswordReset requestPasswordResetUseCase;

  ForgotPasswordRequestViewModel({
    required this.requestPasswordResetUseCase,
  }) : super(ForgotPasswordRequestState.initial());

  Future<void> requestPasswordReset(String email) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      await requestPasswordResetUseCase.execute(email);
      
      state = state.copyWith(
        isLoading: false,
        isRequestSent: true,
        error: () => null,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
        isRequestSent: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to send reset code: ${e.toString()}",
        isRequestSent: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

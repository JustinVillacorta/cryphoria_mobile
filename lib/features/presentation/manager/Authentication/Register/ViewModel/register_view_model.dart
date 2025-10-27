import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'register_state.dart';

class RegisterViewModel extends StateNotifier<RegisterState> {
  final Register registerUseCase;

  RegisterViewModel({
    required this.registerUseCase,
  }) : super(RegisterState.initial());

  Future<void> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, String role) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      final registerResponse = await registerUseCase.execute(
        username, 
        password,
        passwordConfirm, 
        email,
        firstName,
        lastName,
        securityAnswer,
        role: role,
      );
      
      state = state.copyWith(
        isLoading: false,
        authUser: () => registerResponse.data,
        registerResponse: () => registerResponse,
        registerMessage: () => registerResponse.message,
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
        error: () => "Registration failed: ${e.toString()}",
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final AuthUser? authUser;
  final LoginResponse? registerResponse;
  final String registerMessage;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.authUser,
    this.registerResponse,
    this.registerMessage = '',
  });

  factory RegisterState.initial() {
    return const RegisterState();
  }

  RegisterState copyWith({
    bool? isLoading,
    String? Function()? error,
    AuthUser? Function()? authUser,
    LoginResponse? Function()? registerResponse,
    String? registerMessage,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      authUser: authUser != null ? authUser() : this.authUser,
      registerResponse: registerResponse != null ? registerResponse() : this.registerResponse,
      registerMessage: registerMessage ?? this.registerMessage,
    );
  }

  Future<void> register(String trim, String text, String text2, String trim2, String trim3, String trim4, String trim5, String selectedRole) async {}
}

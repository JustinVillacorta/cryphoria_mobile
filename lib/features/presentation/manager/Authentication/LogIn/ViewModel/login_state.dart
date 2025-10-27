import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final AuthUser? authUser;
  final LoginResponse? loginResponse;
  final String? loginMessage;

  LoginState({
    required this.isLoading,
    this.error,
    this.authUser,
    this.loginResponse,
    this.loginMessage,
  });

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      error: null,
      authUser: null,
      loginResponse: null,
      loginMessage: null,
    );
  }

  LoginState copyWith({
    bool? isLoading,
    String? Function()? error,
    AuthUser? Function()? authUser,
    LoginResponse? Function()? loginResponse,
    String? Function()? loginMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      authUser: authUser != null ? authUser() : this.authUser,
      loginResponse: loginResponse != null ? loginResponse() : this.loginResponse,
      loginMessage: loginMessage != null ? loginMessage() : this.loginMessage,
    );
  }
}

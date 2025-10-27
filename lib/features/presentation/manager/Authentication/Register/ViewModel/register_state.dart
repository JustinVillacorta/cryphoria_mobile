import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final AuthUser? authUser;
  final LoginResponse? registerResponse;
  final String? registerMessage;

  RegisterState({
    required this.isLoading,
    this.error,
    this.authUser,
    this.registerResponse,
    this.registerMessage,
  });

  factory RegisterState.initial() {
    return RegisterState(
      isLoading: false,
      error: null,
      authUser: null,
      registerResponse: null,
      registerMessage: null,
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    String? Function()? error,
    AuthUser? Function()? authUser,
    LoginResponse? Function()? registerResponse,
    String? Function()? registerMessage,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      authUser: authUser != null ? authUser() : this.authUser,
      registerResponse: registerResponse != null ? registerResponse() : this.registerResponse,
      registerMessage: registerMessage != null ? registerMessage() : this.registerMessage,
    );
  }
}

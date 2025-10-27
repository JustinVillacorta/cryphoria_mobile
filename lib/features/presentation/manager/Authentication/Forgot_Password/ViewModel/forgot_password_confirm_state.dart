class ForgotPasswordConfirmState {
  final bool isLoading;
  final String? error;
  final bool isPasswordReset;

  ForgotPasswordConfirmState({
    required this.isLoading,
    this.error,
    required this.isPasswordReset,
  });

  factory ForgotPasswordConfirmState.initial() {
    return ForgotPasswordConfirmState(
      isLoading: false,
      error: null,
      isPasswordReset: false,
    );
  }

  ForgotPasswordConfirmState copyWith({
    bool? isLoading,
    String? Function()? error,
    bool? isPasswordReset,
  }) {
    return ForgotPasswordConfirmState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isPasswordReset: isPasswordReset ?? this.isPasswordReset,
    );
  }
}

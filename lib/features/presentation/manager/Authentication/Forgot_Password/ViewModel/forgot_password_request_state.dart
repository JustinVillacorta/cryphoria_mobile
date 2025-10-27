class ForgotPasswordRequestState {
  final bool isLoading;
  final String? error;
  final bool isRequestSent;

  ForgotPasswordRequestState({
    required this.isLoading,
    this.error,
    required this.isRequestSent,
  });

  factory ForgotPasswordRequestState.initial() {
    return ForgotPasswordRequestState(
      isLoading: false,
      error: null,
      isRequestSent: false,
    );
  }

  ForgotPasswordRequestState copyWith({
    bool? isLoading,
    String? Function()? error,
    bool? isRequestSent,
  }) {
    return ForgotPasswordRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isRequestSent: isRequestSent ?? this.isRequestSent,
    );
  }
}

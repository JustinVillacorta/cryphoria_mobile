class LogoutState {
  final bool isLoading;
  final String? error;
  final String? message;
  final bool isLoggedOut;

  LogoutState({
    required this.isLoading,
    this.error,
    this.message,
    required this.isLoggedOut,
  });

  factory LogoutState.initial() {
    return LogoutState(
      isLoading: false,
      error: null,
      message: null,
      isLoggedOut: false,
    );
  }

  LogoutState copyWith({
    bool? isLoading,
    String? Function()? error,
    String? Function()? message,
    bool? isLoggedOut,
  }) {
    return LogoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      message: message != null ? message() : this.message,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}

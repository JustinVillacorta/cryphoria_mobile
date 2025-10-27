class OTPVerificationState {
  final bool isLoading;
  final String? error;
  final bool isVerified;

  OTPVerificationState({
    required this.isLoading,
    this.error,
    required this.isVerified,
  });

  factory OTPVerificationState.initial() {
    return OTPVerificationState(
      isLoading: false,
      error: null,
      isVerified: false,
    );
  }

  OTPVerificationState copyWith({
    bool? isLoading,
    String? Function()? error,
    bool? isVerified,
  }) {
    return OTPVerificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

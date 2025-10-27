import '../../../../domain/entities/support_ticket.dart';

class SupportState {
  final bool isSubmitting;
  final bool isLoadingMessages;
  final String? errorMessage;
  final String? successMessage;
  final List<SupportMessage> supportMessages;

  const SupportState({
    required this.isSubmitting,
    required this.isLoadingMessages,
    this.errorMessage,
    this.successMessage,
    required this.supportMessages,
  });

  factory SupportState.initial() {
    return const SupportState(
      isSubmitting: false,
      isLoadingMessages: false,
      errorMessage: null,
      successMessage: null,
      supportMessages: [],
    );
  }

  SupportState copyWith({
    bool? isSubmitting,
    bool? isLoadingMessages,
    Function()? errorMessage,
    Function()? successMessage,
    List<SupportMessage>? supportMessages,
  }) {
    return SupportState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      supportMessages: supportMessages ?? this.supportMessages,
    );
  }
}

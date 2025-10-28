import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/usecases/Support/submit_support_ticket_usecase.dart';
import '../../../../../domain/usecases/Support/get_support_messages_usecase.dart';
import 'support_state.dart';

class SupportViewModel extends StateNotifier<SupportState> {
  final SubmitSupportTicketUseCase submitSupportTicketUseCase;
  final GetSupportMessagesUseCase getSupportMessagesUseCase;

  SupportViewModel({
    required this.submitSupportTicketUseCase,
    required this.getSupportMessagesUseCase,
  }) : super(SupportState.initial());

  void clearMessages() {
    state = state.copyWith(
      errorMessage: () => null,
      successMessage: () => null,
    );
  }

  Future<bool> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<String>? attachments,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: () => null,
      successMessage: () => null,
    );

    try {
      final ticket = await submitSupportTicketUseCase.execute(
        subject: subject,
        message: message,
        category: category,
        priority: priority,
        attachments: attachments,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: () => 'Support ticket submitted successfully! Ticket ID: ${ticket.id}',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> loadSupportMessages() async {
    state = state.copyWith(
      isLoadingMessages: true,
      errorMessage: () => null,
    );

    try {
      final messages = await getSupportMessagesUseCase.execute();
      state = state.copyWith(
        isLoadingMessages: false,
        supportMessages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMessages: false,
        errorMessage: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshSupportMessages() async {
    await loadSupportMessages();
  }
}
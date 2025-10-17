import 'package:flutter/material.dart';
import '../../../../domain/entities/support_ticket.dart';
import '../../../../domain/usecases/Support/submit_support_ticket_usecase.dart';
import '../../../../domain/usecases/Support/get_support_messages_usecase.dart';

class SupportViewModel extends ChangeNotifier {
  final SubmitSupportTicketUseCase submitSupportTicketUseCase;
  final GetSupportMessagesUseCase getSupportMessagesUseCase;

  SupportViewModel({
    required this.submitSupportTicketUseCase,
    required this.getSupportMessagesUseCase,
  });

  // State variables
  bool _isSubmitting = false;
  bool _isLoadingMessages = false;
  String? _errorMessage;
  String? _successMessage;
  List<SupportMessage> _supportMessages = [];

  // Getters
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<SupportMessage> get supportMessages => _supportMessages;

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Submit support ticket
  Future<bool> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<String>? attachments,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final ticket = await submitSupportTicketUseCase.execute(
        subject: subject,
        message: message,
        category: category,
        priority: priority,
        attachments: attachments,
      );

      _successMessage = 'Support ticket submitted successfully! Ticket ID: ${ticket.id}';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Get support messages
  Future<void> loadSupportMessages() async {
    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = await getSupportMessagesUseCase.execute();
      _supportMessages = messages;
      _isLoadingMessages = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Refresh support messages
  Future<void> refreshSupportMessages() async {
    await loadSupportMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

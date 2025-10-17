import '../../entities/support_ticket.dart';
import '../../repositories/support_repository.dart';

class SubmitSupportTicketUseCase {
  final SupportRepository repository;

  SubmitSupportTicketUseCase({required this.repository});

  Future<SupportTicket> execute({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<String>? attachments,
  }) async {
    // Validate required fields
    if (subject.trim().isEmpty) {
      throw Exception('Subject is required');
    }
    if (message.trim().isEmpty) {
      throw Exception('Message is required');
    }
    if (category.trim().isEmpty) {
      throw Exception('Category is required');
    }
    if (priority.trim().isEmpty) {
      throw Exception('Priority is required');
    }

    // Validate subject length
    if (subject.length > 200) {
      throw Exception('Subject must be 200 characters or less');
    }

    // Validate message length
    if (message.length < 10) {
      throw Exception('Message must be at least 10 characters long');
    }
    if (message.length > 2000) {
      throw Exception('Message must be 2000 characters or less');
    }

    return await repository.submitSupportTicket(
      subject: subject.trim(),
      message: message.trim(),
      category: category.trim(),
      priority: priority.trim(),
      attachments: attachments,
    );
  }
}

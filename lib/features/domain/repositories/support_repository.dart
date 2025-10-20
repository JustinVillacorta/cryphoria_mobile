import '../entities/support_ticket.dart';

abstract class SupportRepository {
  Future<SupportTicket> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<String>? attachments,
  });

  Future<List<SupportMessage>> getSupportMessages();
}

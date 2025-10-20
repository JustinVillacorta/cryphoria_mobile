import 'dart:io';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';
import '../data_sources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupportTicket> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<String>? attachments,
  }) async {
    try {
      // Convert String paths to File objects
      List<File>? attachmentFiles;
      if (attachments != null && attachments.isNotEmpty) {
        attachmentFiles = attachments
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();
      }

      return await remoteDataSource.submitSupportTicket(
        subject: subject,
        message: message,
        category: category,
        priority: priority,
        attachments: attachmentFiles,
      );
    } catch (e) {
      print("❌ SupportRepositoryImpl.submitSupportTicket error: $e");
      rethrow;
    }
  }

  @override
  Future<List<SupportMessage>> getSupportMessages() async {
    try {
      return await remoteDataSource.getSupportMessages();
    } catch (e) {
      print("❌ SupportRepositoryImpl.getSupportMessages error: $e");
      rethrow;
    }
  }
}

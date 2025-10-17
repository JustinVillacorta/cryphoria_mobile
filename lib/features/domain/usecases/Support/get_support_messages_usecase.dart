import '../../entities/support_ticket.dart';
import '../../repositories/support_repository.dart';

class GetSupportMessagesUseCase {
  final SupportRepository repository;

  GetSupportMessagesUseCase({required this.repository});

  Future<List<SupportMessage>> execute() async {
    return await repository.getSupportMessages();
  }
}

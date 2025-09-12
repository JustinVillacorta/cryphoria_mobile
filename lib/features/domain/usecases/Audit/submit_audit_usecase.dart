import '../../entities/smart_contract.dart';
import '../../repositories/audit_repository.dart';

class SubmitAuditUseCase {
  final AuditRepository repository;

  SubmitAuditUseCase(this.repository);

  Future<String> execute(AuditRequest request) async {
    return await repository.submitAuditRequest(request);
  }
}

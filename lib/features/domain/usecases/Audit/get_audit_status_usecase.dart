import '../../entities/audit_report.dart';
import '../../repositories/audit_repository.dart';

class GetAuditStatusUseCase {
  final AuditRepository repository;

  GetAuditStatusUseCase(this.repository);

  Future<AuditStatus> execute(String auditId) async {
    return await repository.getAuditStatus(auditId);
  }
}

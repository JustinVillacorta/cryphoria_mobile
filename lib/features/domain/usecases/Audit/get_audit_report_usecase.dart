import '../../entities/audit_report.dart';
import '../../repositories/audit_repository.dart';

class GetAuditReportUseCase {
  final AuditRepository repository;

  GetAuditReportUseCase(this.repository);

  Future<AuditReport> execute(String auditId) async {
    return await repository.getAuditReport(auditId);
  }
}

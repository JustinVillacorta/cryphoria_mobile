import 'dart:io';
import '../../entities/audit_report.dart';
import '../../repositories/audit_repository.dart';

class UploadContractUseCase {
  final AuditRepository repository;

  UploadContractUseCase(this.repository);

  Future<AuditReport> execute(File contractFile) async {
    return await repository.uploadContract(contractFile);
  }
}
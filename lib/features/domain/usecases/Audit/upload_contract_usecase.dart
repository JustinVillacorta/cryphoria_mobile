import '../../entities/smart_contract.dart';
import '../../repositories/audit_repository.dart';

class UploadContractUseCase {
  final AuditRepository repository;

  UploadContractUseCase(this.repository);

  Future<SmartContract> execute(String name, String fileName, String sourceCode) async {
    return await repository.uploadContract(name, fileName, sourceCode);
  }
}

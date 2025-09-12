import '../../domain/entities/audit_report.dart';
import '../../domain/entities/smart_contract.dart';
import '../../domain/repositories/audit_repository.dart';
import '../data_sources/audit_remote_data_source.dart';
import '../models/audit/smart_contract_model.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> submitAuditRequest(AuditRequest request) async {
    final requestModel = AuditRequestModel.fromDomain(request);
    return await remoteDataSource.submitAuditRequest(requestModel);
  }

  @override
  Future<AuditStatus> getAuditStatus(String auditId) async {
    return await remoteDataSource.getAuditStatus(auditId);
  }

  @override
  Future<AuditReport> getAuditReport(String auditId) async {
    return await remoteDataSource.getAuditReport(auditId);
  }

  @override
  Future<List<AuditReport>> getUserAuditReports() async {
    final reportModels = await remoteDataSource.getUserAuditReports();
    return reportModels.cast<AuditReport>();
  }

  @override
  Future<bool> cancelAudit(String auditId) async {
    return await remoteDataSource.cancelAudit(auditId);
  }

  @override
  Future<SmartContract> uploadContract(String name, String fileName, String sourceCode) async {
    return await remoteDataSource.uploadContract(name, fileName, sourceCode);
  }

  @override
  Future<SmartContract> getContract(String contractId) async {
    return await remoteDataSource.getContract(contractId);
  }

  @override
  Future<bool> deleteContract(String contractId) async {
    return await remoteDataSource.deleteContract(contractId);
  }

  @override
  Future<List<ContractType>> getSupportedContractTypes() async {
    return await remoteDataSource.getSupportedContractTypes();
  }

  @override
  Future<bool> validateContractCode(String sourceCode) async {
    return await remoteDataSource.validateContractCode(sourceCode);
  }
}

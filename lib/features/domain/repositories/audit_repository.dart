import '../entities/audit_report.dart';
import '../entities/smart_contract.dart';

abstract class AuditRepository {
  /// Submit a smart contract for audit
  Future<String> submitAuditRequest(AuditRequest request);
  
  /// Get audit status by audit ID
  Future<AuditStatus> getAuditStatus(String auditId);
  
  /// Get completed audit report
  Future<AuditReport> getAuditReport(String auditId);
  
  /// Get all audit reports for the current user
  Future<List<AuditReport>> getUserAuditReports();
  
  /// Cancel an ongoing audit
  Future<bool> cancelAudit(String auditId);
  
  /// Upload smart contract file
  Future<SmartContract> uploadContract(String name, String fileName, String sourceCode);
  
  /// Get contract details
  Future<SmartContract> getContract(String contractId);
  
  /// Delete a contract
  Future<bool> deleteContract(String contractId);
  
  /// Get supported contract types
  Future<List<ContractType>> getSupportedContractTypes();
  
  /// Validate contract source code
  Future<bool> validateContractCode(String sourceCode);
}

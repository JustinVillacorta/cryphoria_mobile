import '../../../domain/entities/smart_contract.dart';

class SmartContractModel extends SmartContract {
  const SmartContractModel({
    required super.id,
    required super.name,
    required super.fileName,
    required super.sourceCode,
    super.bytecode,
    required super.contractAddress,
    required super.type,
    required super.uploadedAt,
    super.sourceFile,
  });

  factory SmartContractModel.fromJson(Map<String, dynamic> json) {
    return SmartContractModel(
      id: json['id'] as String? ?? json['audit_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? json['contract_name'] as String? ?? 'Unknown Contract',
      fileName: json['file_name'] as String? ?? json['fileName'] as String? ?? 'contract.sol',
      sourceCode: json['source_code'] as String? ?? json['sourceCode'] as String? ?? '',
      bytecode: json['bytecode'] as String?,
      contractAddress: json['contract_address'] as String? ?? json['contractAddress'] as String? ?? '',
      type: _parseContractType(json['type'] as String?),
      uploadedAt: _parseDateTime(json['uploaded_at'] as String? ?? json['uploadedAt'] as String?),
    );
  }

  static ContractType _parseContractType(String? typeStr) {
    if (typeStr == null) return ContractType.custom;
    return ContractType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ContractType.custom,
    );
  }

  static DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_name': fileName,
      'source_code': sourceCode,
      'bytecode': bytecode,
      'contract_address': contractAddress,
      'type': type.name,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

class AuditRequestModel extends AuditRequest {
  const AuditRequestModel({
    required super.contractId,
    required super.contractName,
    required super.fileName,
    required super.sourceCode,
    required super.options,
    required super.requestedAt,
  });

  factory AuditRequestModel.fromDomain(AuditRequest request) {
    return AuditRequestModel(
      contractId: request.contractId,
      contractName: request.contractName,
      fileName: request.fileName,
      sourceCode: request.sourceCode,
      options: request.options,
      requestedAt: request.requestedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract_id': contractId,
      'contract_name': contractName,
      'file_name': fileName,
      'source_code': sourceCode,
      'options': {
        'include_gas_optimization': options.includeGasOptimization,
        'include_security_analysis': options.includeSecurityAnalysis,
        'include_code_quality': options.includeCodeQuality,
        'include_vulnerability_scanning': options.includeVulnerabilityScanning,
        'specific_checks': options.specificChecks,
      },
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
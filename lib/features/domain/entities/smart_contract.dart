import 'dart:io';

class SmartContract {
  final String id;
  final String name;
  final String fileName;
  final String sourceCode;
  final String? bytecode;
  final String contractAddress;
  final ContractType type;
  final DateTime uploadedAt;
  final File? sourceFile;

  const SmartContract({
    required this.id,
    required this.name,
    required this.fileName,
    required this.sourceCode,
    this.bytecode,
    required this.contractAddress,
    required this.type,
    required this.uploadedAt,
    this.sourceFile,
  });

  SmartContract copyWith({
    String? id,
    String? name,
    String? fileName,
    String? sourceCode,
    String? bytecode,
    String? contractAddress,
    ContractType? type,
    DateTime? uploadedAt,
    File? sourceFile,
  }) {
    return SmartContract(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      sourceCode: sourceCode ?? this.sourceCode,
      bytecode: bytecode ?? this.bytecode,
      contractAddress: contractAddress ?? this.contractAddress,
      type: type ?? this.type,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      sourceFile: sourceFile ?? this.sourceFile,
    );
  }
}

class AuditRequest {
  final String contractId;
  final String contractName;
  final String fileName;
  final String sourceCode;
  final AuditOptions options;
  final DateTime requestedAt;

  const AuditRequest({
    required this.contractId,
    required this.contractName,
    required this.fileName,
    required this.sourceCode,
    required this.options,
    required this.requestedAt,
  });
}

class AuditOptions {
  final bool includeGasOptimization;
  final bool includeSecurityAnalysis;
  final bool includeCodeQuality;
  final bool includeVulnerabilityScanning;
  final List<String> specificChecks;

  const AuditOptions({
    this.includeGasOptimization = true,
    this.includeSecurityAnalysis = true,
    this.includeCodeQuality = true,
    this.includeVulnerabilityScanning = true,
    this.specificChecks = const [],
  });
}

enum ContractType {
  erc20,
  erc721,
  erc1155,
  deFi,
  dao,
  custom,
}

extension ContractTypeExtension on ContractType {
  String get displayName {
    switch (this) {
      case ContractType.erc20:
        return 'ERC-20 Token';
      case ContractType.erc721:
        return 'ERC-721 NFT';
      case ContractType.erc1155:
        return 'ERC-1155 Multi-Token';
      case ContractType.deFi:
        return 'DeFi Protocol';
      case ContractType.dao:
        return 'DAO Contract';
      case ContractType.custom:
        return 'Custom Contract';
    }
  }
}
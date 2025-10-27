import 'dart:io';
import '../../../../domain/entities/audit_report.dart';

class AuditUploadState {
  final bool isLoading;
  final String? error;
  final AuditReport? currentAuditReport;
  final String contractName;
  final File? selectedFile;
  final bool canProceed;

  const AuditUploadState({
    required this.isLoading,
    this.error,
    this.currentAuditReport,
    required this.contractName,
    this.selectedFile,
    required this.canProceed,
  });

  factory AuditUploadState.initial() {
    return const AuditUploadState(
      isLoading: false,
      error: null,
      currentAuditReport: null,
      contractName: '',
      selectedFile: null,
      canProceed: false,
    );
  }

  AuditUploadState copyWith({
    bool? isLoading,
    Function()? error,
    Function()? currentAuditReport,
    String? contractName,
    Function()? selectedFile,
    bool? canProceed,
  }) {
    return AuditUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      currentAuditReport: currentAuditReport != null ? currentAuditReport() : this.currentAuditReport,
      contractName: contractName ?? this.contractName,
      selectedFile: selectedFile != null ? selectedFile() : this.selectedFile,
      canProceed: canProceed ?? this.canProceed,
    );
  }
}

import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/entities/smart_contract.dart';

enum AuditFlowStep {
  contractSetup,
  analysis,
  results,
  assessment,
}

class AuditFlowState {
  final AuditFlowStep currentFlow;
  final SmartContract? currentContract;
  final String? currentAuditId;
  final AuditReport? currentAuditReport;
  final String? error;
  final bool canProceedToAnalysis;
  final bool canProceedToResults;
  final bool hasCompletedAudit;

  const AuditFlowState({
    required this.currentFlow,
    this.currentContract,
    this.currentAuditId,
    this.currentAuditReport,
    this.error,
    required this.canProceedToAnalysis,
    required this.canProceedToResults,
    required this.hasCompletedAudit,
  });

  factory AuditFlowState.initial() {
    return const AuditFlowState(
      currentFlow: AuditFlowStep.contractSetup,
      currentContract: null,
      currentAuditId: null,
      currentAuditReport: null,
      error: null,
      canProceedToAnalysis: false,
      canProceedToResults: false,
      hasCompletedAudit: false,
    );
  }

  AuditFlowState copyWith({
    AuditFlowStep? currentFlow,
    Function()? currentContract,
    Function()? currentAuditId,
    Function()? currentAuditReport,
    Function()? error,
    bool? canProceedToAnalysis,
    bool? canProceedToResults,
    bool? hasCompletedAudit,
  }) {
    return AuditFlowState(
      currentFlow: currentFlow ?? this.currentFlow,
      currentContract: currentContract != null ? currentContract() : this.currentContract,
      currentAuditId: currentAuditId != null ? currentAuditId() : this.currentAuditId,
      currentAuditReport: currentAuditReport != null ? currentAuditReport() : this.currentAuditReport,
      error: error != null ? error() : this.error,
      canProceedToAnalysis: canProceedToAnalysis ?? this.canProceedToAnalysis,
      canProceedToResults: canProceedToResults ?? this.canProceedToResults,
      hasCompletedAudit: hasCompletedAudit ?? this.hasCompletedAudit,
    );
  }

  double getFlowProgress() {
    switch (currentFlow) {
      case AuditFlowStep.contractSetup:
        return 0.25;
      case AuditFlowStep.analysis:
        return 0.5;
      case AuditFlowStep.results:
        return 0.75;
      case AuditFlowStep.assessment:
        return 1.0;
    }
  }

  String getFlowDescription() {
    switch (currentFlow) {
      case AuditFlowStep.contractSetup:
        return 'Set up your smart contract for audit';
      case AuditFlowStep.analysis:
        return 'AI is analyzing your smart contract';
      case AuditFlowStep.results:
        return 'Review detailed audit results';
      case AuditFlowStep.assessment:
        return 'Overall security assessment';
    }
  }
}

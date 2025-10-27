import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/entities/smart_contract.dart';
import 'audit_flow_state.dart';

export 'audit_flow_state.dart';

class AuditFlowViewModel extends StateNotifier<AuditFlowState> {
  AuditFlowViewModel() : super(AuditFlowState.initial());

  void setCurrentContract(SmartContract contract) {
    state = state.copyWith(
      currentContract: () => contract,
      error: () => null,
      canProceedToAnalysis: true,
    );
  }

  void setCurrentAuditId(String auditId) {
    state = state.copyWith(
      currentAuditId: () => auditId,
      error: () => null,
      canProceedToResults: true,
    );
  }

  void setCurrentAuditReport(AuditReport report) {
    state = state.copyWith(
      currentAuditReport: () => report,
      error: () => null,
      hasCompletedAudit: true,
    );
  }

  void moveToContractSetup() {
    state = state.copyWith(currentFlow: AuditFlowStep.contractSetup);
  }

  void moveToAnalysis() {
    if (!state.canProceedToAnalysis) {
      state = state.copyWith(
        error: () => 'Contract setup must be completed first',
      );
      return;
    }

    state = state.copyWith(
      currentFlow: AuditFlowStep.analysis,
      error: () => null,
    );
  }

  void moveToResults() {
    if (!state.canProceedToResults) {
      state = state.copyWith(
        error: () => 'Analysis must be completed first',
      );
      return;
    }

    state = state.copyWith(
      currentFlow: AuditFlowStep.results,
      error: () => null,
    );
  }

  void moveToAssessment() {
    if (!state.hasCompletedAudit) {
      state = state.copyWith(
        error: () => 'Audit must be completed first',
      );
      return;
    }

    state = state.copyWith(
      currentFlow: AuditFlowStep.assessment,
      error: () => null,
    );
  }

  void resetAuditFlow() {
    state = AuditFlowState.initial();
  }

  bool canNavigateBack() {
    return state.currentFlow != AuditFlowStep.contractSetup;
  }

  void navigateBack() {
    switch (state.currentFlow) {
      case AuditFlowStep.analysis:
        moveToContractSetup();
        break;
      case AuditFlowStep.results:
        moveToAnalysis();
        break;
      case AuditFlowStep.assessment:
        moveToResults();
        break;
      case AuditFlowStep.contractSetup:
        break;
    }
  }
}

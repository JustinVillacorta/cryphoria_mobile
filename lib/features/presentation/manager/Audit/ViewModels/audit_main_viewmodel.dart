import 'package:flutter/material.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/entities/smart_contract.dart';

class AuditMainViewModel extends ChangeNotifier {
  AuditFlowState _currentFlow = AuditFlowState.contractSetup;
  SmartContract? _currentContract;
  String? _currentAuditId;
  AuditReport? _currentAuditReport;
  String? _error;

  AuditFlowState get currentFlow => _currentFlow;
  SmartContract? get currentContract => _currentContract;
  String? get currentAuditId => _currentAuditId;
  AuditReport? get currentAuditReport => _currentAuditReport;
  String? get error => _error;

  bool get canProceedToAnalysis => _currentContract != null;
  bool get canProceedToResults => _currentAuditId != null;
  bool get hasCompletedAudit => _currentAuditReport != null;

  void setCurrentContract(SmartContract contract) {
    _currentContract = contract;
    _clearError();
    notifyListeners();
  }

  void setCurrentAuditId(String auditId) {
    _currentAuditId = auditId;
    _clearError();
    notifyListeners();
  }

  void setCurrentAuditReport(AuditReport report) {
    _currentAuditReport = report;
    _clearError();
    notifyListeners();
  }

  void moveToContractSetup() {
    _currentFlow = AuditFlowState.contractSetup;
    notifyListeners();
  }

  void moveToAnalysis() {
    if (!canProceedToAnalysis) {
      _setError('Contract setup must be completed first');
      return;
    }

    _currentFlow = AuditFlowState.analysis;
    _clearError();
    notifyListeners();
  }

  void moveToResults() {
    if (!canProceedToResults) {
      _setError('Analysis must be completed first');
      return;
    }

    _currentFlow = AuditFlowState.results;
    _clearError();
    notifyListeners();
  }

  void moveToAssessment() {
    if (!hasCompletedAudit) {
      _setError('Audit must be completed first');
      return;
    }

    _currentFlow = AuditFlowState.assessment;
    _clearError();
    notifyListeners();
  }

  void resetAuditFlow() {
    _currentFlow = AuditFlowState.contractSetup;
    _currentContract = null;
    _currentAuditId = null;
    _currentAuditReport = null;
    _clearError();
    notifyListeners();
  }

  bool canNavigateBack() {
    return _currentFlow != AuditFlowState.contractSetup;
  }

  void navigateBack() {
    switch (_currentFlow) {
      case AuditFlowState.analysis:
        moveToContractSetup();
        break;
      case AuditFlowState.results:
        moveToAnalysis();
        break;
      case AuditFlowState.assessment:
        moveToResults();
        break;
      case AuditFlowState.contractSetup:
        break;
    }
  }

  double getFlowProgress() {
    switch (_currentFlow) {
      case AuditFlowState.contractSetup:
        return 0.25;
      case AuditFlowState.analysis:
        return 0.5;
      case AuditFlowState.results:
        return 0.75;
      case AuditFlowState.assessment:
        return 1.0;
    }
  }

  String getFlowDescription() {
    switch (_currentFlow) {
      case AuditFlowState.contractSetup:
        return 'Set up your smart contract for audit';
      case AuditFlowState.analysis:
        return 'AI is analyzing your smart contract';
      case AuditFlowState.results:
        return 'Review detailed audit results';
      case AuditFlowState.assessment:
        return 'Overall security assessment';
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

enum AuditFlowState {
  contractSetup,
  analysis,
  results,
  assessment,
}
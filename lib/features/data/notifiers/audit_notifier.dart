import 'package:flutter/foundation.dart';
import '../../domain/entities/audit_report.dart';
import '../../domain/entities/smart_contract.dart';
import '../../domain/usecases/Audit/submit_audit_usecase.dart';
import '../../domain/usecases/Audit/get_audit_report_usecase.dart';
import '../../domain/usecases/Audit/get_audit_status_usecase.dart';
import '../../domain/usecases/Audit/upload_contract_usecase.dart';

class AuditNotifier extends ChangeNotifier {
  final SubmitAuditUseCase submitAuditUseCase;
  final GetAuditReportUseCase getAuditReportUseCase;
  final GetAuditStatusUseCase getAuditStatusUseCase;
  final UploadContractUseCase uploadContractUseCase;

  AuditNotifier({
    required this.submitAuditUseCase,
    required this.getAuditReportUseCase,
    required this.getAuditStatusUseCase,
    required this.uploadContractUseCase,
  });

  // State variables
  bool _isLoading = false;
  String? _error;
  SmartContract? _currentContract;
  AuditReport? _currentAuditReport;
  AuditStatus? _currentAuditStatus;
  String? _currentAuditId;
  List<String> _analysisSteps = [];
  int _currentStepIndex = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  SmartContract? get currentContract => _currentContract;
  AuditReport? get currentAuditReport => _currentAuditReport;
  AuditStatus? get currentAuditStatus => _currentAuditStatus;
  String? get currentAuditId => _currentAuditId;
  List<String> get analysisSteps => _analysisSteps;
  int get currentStepIndex => _currentStepIndex;

  // Upload contract
  Future<void> uploadContract(String name, String fileName, String sourceCode) async {
    print("📊 AuditNotifier.uploadContract called");
    print("📋 Name: $name");
    print("📁 FileName: $fileName");
    print("📄 Source code length: ${sourceCode.length}");
    
    _setLoading(true);
    _clearError();

    try {
      print("🔄 Calling uploadContractUseCase.execute...");
      _currentContract = await uploadContractUseCase.execute(name, fileName, sourceCode);
      print("✅ Contract uploaded successfully: ${_currentContract?.id}");
      notifyListeners();
    } catch (e) {
      print("❌ Error in uploadContract: $e");
      _setError('Failed to upload contract: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Submit audit request
  Future<void> submitAuditRequest(AuditRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      print("🔄 AuditNotifier.submitAuditRequest: About to call submitAuditUseCase.execute");
      final auditId = await submitAuditUseCase.execute(request);
      print("✅ AuditNotifier.submitAuditRequest: Received audit ID: $auditId");
      
      _currentAuditId = auditId;
      _currentAuditStatus = AuditStatus.pending;
      
      print("📊 AuditNotifier.submitAuditRequest: Set currentAuditId to: $_currentAuditId");
      
      // Initialize analysis steps
      _analysisSteps = [
        'Parsing smart contract code',
        'Analyzing contract structure',
        'Identifying potential vulnerabilities',
        'Performing security checks',
        'Running gas optimization analysis',
        'Generating comprehensive report',
      ];
      _currentStepIndex = 0;
      
      notifyListeners();
      
      // Don't start automatic polling here - let the UI handle it
    } catch (e) {
      _setError('Failed to submit audit request: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Get audit status
  Future<void> getAuditStatus(String auditId) async {
    try {
      _currentAuditStatus = await getAuditStatusUseCase.execute(auditId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get audit status: ${e.toString()}');
    }
  }

  // Get audit report
  Future<void> getAuditReport(String auditId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentAuditReport = await getAuditReportUseCase.execute(auditId);
      _currentAuditStatus = _currentAuditReport!.status;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get audit report: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset audit state
  void resetAudit() {
    _currentContract = null;
    _currentAuditReport = null;
    _currentAuditStatus = null;
    _currentAuditId = null;
    _analysisSteps = [];
    _currentStepIndex = 0;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

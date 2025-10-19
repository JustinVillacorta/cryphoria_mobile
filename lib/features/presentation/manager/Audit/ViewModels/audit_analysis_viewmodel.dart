import 'package:flutter/material.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/entities/smart_contract.dart';
import '../../../../domain/usecases/Audit/submit_audit_usecase.dart';
import '../../../../domain/usecases/Audit/get_audit_status_usecase.dart';

class AuditAnalysisViewModel extends ChangeNotifier {
  final SubmitAuditUseCase submitAuditUseCase;
  final GetAuditStatusUseCase getAuditStatusUseCase;

  AuditAnalysisViewModel({
    required this.submitAuditUseCase,
    required this.getAuditStatusUseCase,
  });

  // State
  bool _isLoading = false;
  String? _error;
  String? _currentAuditId;
  AuditStatus _currentStatus = AuditStatus.pending;
  double _analysisProgress = 0.0;
  int _currentStepIndex = 0;
  
  final List<String> _analysisSteps = [
    'Parsing smart contract code',
    'Analyzing contract structure',
    'Identifying potential vulnerabilities',
    'Performing security checks',
    'Running gas optimization analysis',
    'Generating comprehensive report',
  ];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentAuditId => _currentAuditId;
  AuditStatus get currentStatus => _currentStatus;
  double get analysisProgress => _analysisProgress;
  int get currentStepIndex => _currentStepIndex;
  List<String> get analysisSteps => List.unmodifiable(_analysisSteps);
  String get currentStepDescription => _currentStepIndex < _analysisSteps.length 
      ? _analysisSteps[_currentStepIndex] 
      : 'Analysis complete';
  bool get isAnalysisComplete => _currentStatus == AuditStatus.completed;

  // Start analysis
  Future<bool> startAnalysis(AuditRequest auditRequest) async {
    _setLoading(true);
    _clearError();
    _resetProgress();

    try {
      // Submit audit request
      _currentAuditId = await submitAuditUseCase.execute(auditRequest);
      _currentStatus = AuditStatus.pending;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start analysis: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update analysis progress (for UI animation)
  void updateProgress(double progress) {
    _analysisProgress = progress.clamp(0.0, 1.0);
    _currentStepIndex = (_analysisProgress * _analysisSteps.length).floor()
        .clamp(0, _analysisSteps.length - 1);
    notifyListeners();
  }

  // Check audit status
  Future<AuditStatus> checkStatus() async {
    if (_currentAuditId == null) {
      throw Exception('No audit ID available');
    }

    try {
      _currentStatus = await getAuditStatusUseCase.execute(_currentAuditId!);
      notifyListeners();
      return _currentStatus;
    } catch (e) {
      _setError('Failed to check status: ${e.toString()}');
      rethrow;
    }
  }

  // Poll for completion
  Future<bool> pollForCompletion({
    int maxAttempts = 30,
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    if (_currentAuditId == null) {
      print("❌ AuditAnalysisViewModel: No audit ID available for polling");
      return false;
    }

    print("🔄 AuditAnalysisViewModel: Starting polling for audit ID: $_currentAuditId");
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        print("📊 Polling attempt ${attempts + 1}/$maxAttempts");
        final status = await checkStatus();
        print("📈 Current status: $status");
        
        if (status == AuditStatus.completed) {
          print("✅ AuditAnalysisViewModel: Audit completed successfully!");
          _analysisProgress = 1.0;
          _currentStepIndex = _analysisSteps.length - 1;
          notifyListeners();
          return true;
        } else if (status == AuditStatus.failed) {
          print("❌ AuditAnalysisViewModel: Audit failed");
          _setError('Analysis failed');
          return false;
        }
        
        attempts++;
        print("⏳ Waiting ${pollInterval.inSeconds} seconds before next attempt...");
        await Future.delayed(pollInterval);
      } catch (e) {
        print("❌ AuditAnalysisViewModel: Error during polling attempt $attempts - $e");
        _setError('Error during polling: ${e.toString()}');
        return false;
      }
    }
    
    print("⏰ AuditAnalysisViewModel: Polling timeout after $maxAttempts attempts");
    _setError('Analysis timeout - please try again');
    return false;
  }

  // Reset state
  void reset() {
    _currentAuditId = null;
    _currentStatus = AuditStatus.pending;
    _resetProgress();
    _clearError();
    notifyListeners();
  }

  void _resetProgress() {
    _analysisProgress = 0.0;
    _currentStepIndex = 0;
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
}

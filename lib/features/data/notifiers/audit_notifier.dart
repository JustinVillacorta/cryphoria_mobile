import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/audit_report.dart';
import '../../domain/usecases/Audit/upload_contract_usecase.dart';

class AuditNotifier extends ChangeNotifier {
  final UploadContractUseCase uploadContractUseCase;

  AuditNotifier({
    required this.uploadContractUseCase,
  });

  // State variables
  bool _isLoading = false;
  String? _error;
  AuditReport? _currentAuditReport;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuditReport? get currentAuditReport => _currentAuditReport;

  // Upload contract and get immediate audit report
  Future<void> uploadContract(File contractFile) async {
    print("📊 AuditNotifier.uploadContract called");
    print("📁 File: ${contractFile.path}");
    
    _setLoading(true);
    _clearError();

    try {
      print("🔄 Calling uploadContractUseCase.execute...");
      _currentAuditReport = await uploadContractUseCase.execute(contractFile);
      print("✅ Contract uploaded and audit completed: ${_currentAuditReport?.id}");
      
      notifyListeners();
    } catch (e) {
      print("❌ Error in uploadContract: $e");
      _setError('Failed to upload contract: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset audit state
  void resetAudit() {
    _currentAuditReport = null;
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

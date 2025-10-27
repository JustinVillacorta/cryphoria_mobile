import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/audit_report.dart';
import '../../domain/usecases/Audit/upload_contract_usecase.dart';

class AuditNotifier extends ChangeNotifier {
  final UploadContractUseCase uploadContractUseCase;

  AuditNotifier({
    required this.uploadContractUseCase,
  });

  bool _isLoading = false;
  String? _error;
  AuditReport? _currentAuditReport;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuditReport? get currentAuditReport => _currentAuditReport;

  Future<void> uploadContract(File contractFile) async {

    _setLoading(true);
    _clearError();

    try {
      _currentAuditReport = await uploadContractUseCase.execute(contractFile);

      notifyListeners();
    } catch (e) {
      _setError('Failed to upload contract: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void resetAudit() {
    _currentAuditReport = null;
    _clearError();
    notifyListeners();
  }

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
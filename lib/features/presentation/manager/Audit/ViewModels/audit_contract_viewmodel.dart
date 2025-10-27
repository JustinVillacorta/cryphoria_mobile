import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../../domain/usecases/Audit/upload_contract_usecase.dart';

class AuditContractViewModel extends ChangeNotifier {
  final UploadContractUseCase uploadContractUseCase;

  AuditContractViewModel({
    required this.uploadContractUseCase,
  });

  bool _isLoading = false;
  String? _error;
  AuditReport? _currentAuditReport;
  String _contractName = '';
  File? _selectedFile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuditReport? get currentAuditReport => _currentAuditReport;
  String get contractName => _contractName;
  File? get selectedFile => _selectedFile;
  bool get canProceed => _contractName.isNotEmpty && _selectedFile != null;

  void updateContractName(String name) {
    _contractName = name.trim();
    _clearError();
    notifyListeners();
  }

  void selectFile(File file) {
    _selectedFile = file;
    _clearError();
    notifyListeners();
  }

  void clearFile() {
    _selectedFile = null;
    notifyListeners();
  }

  Future<bool> uploadContract() async {
    if (!canProceed) {
      _setError('Please fill all required fields');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _currentAuditReport = await uploadContractUseCase.execute(_selectedFile!);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to upload contract: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _currentAuditReport = null;
    _contractName = '';
    _selectedFile = null;
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
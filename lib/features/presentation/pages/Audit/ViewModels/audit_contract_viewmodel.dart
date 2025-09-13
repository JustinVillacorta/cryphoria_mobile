import 'package:flutter/material.dart';
import '../../../../domain/entities/smart_contract.dart';
import '../../../../domain/usecases/Audit/upload_contract_usecase.dart';

class AuditContractViewModel extends ChangeNotifier {
  final UploadContractUseCase uploadContractUseCase;

  AuditContractViewModel({
    required this.uploadContractUseCase,
  });

  // State
  bool _isLoading = false;
  String? _error;
  SmartContract? _currentContract;
  String _contractName = '';
  String? _selectedFileName;
  String? _sourceCode;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  SmartContract? get currentContract => _currentContract;
  String get contractName => _contractName;
  String? get selectedFileName => _selectedFileName;
  bool get canProceed => _contractName.isNotEmpty && 
                        _selectedFileName != null && 
                        _sourceCode != null && 
                        _sourceCode!.isNotEmpty;

  // Contract name validation
  void updateContractName(String name) {
    _contractName = name.trim();
    _clearError();
    notifyListeners();
  }

  // File selection and validation
  void selectFile(String fileName, String sourceCode) {
    _selectedFileName = fileName;
    _sourceCode = sourceCode;
    _clearError();
    notifyListeners();
  }

  void clearFile() {
    _selectedFileName = null;
    _sourceCode = null;
    notifyListeners();
  }

  // Upload contract
  Future<bool> uploadContract() async {
    if (!canProceed) {
      _setError('Please fill all required fields');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _currentContract = await uploadContractUseCase.execute(
        _contractName,
        _selectedFileName!,
        _sourceCode!,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to upload contract: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset state
  void reset() {
    _currentContract = null;
    _contractName = '';
    _selectedFileName = null;
    _sourceCode = null;
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
}

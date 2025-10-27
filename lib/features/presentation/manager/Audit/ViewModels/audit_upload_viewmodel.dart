import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/Audit/upload_contract_usecase.dart';
import 'audit_upload_state.dart';

class AuditUploadViewModel extends StateNotifier<AuditUploadState> {
  final UploadContractUseCase uploadContractUseCase;

  AuditUploadViewModel({
    required this.uploadContractUseCase,
  }) : super(AuditUploadState.initial());

  void updateContractName(String name) {
    final trimmedName = name.trim();
    state = state.copyWith(
      contractName: trimmedName,
      error: () => null,
      canProceed: trimmedName.isNotEmpty && state.selectedFile != null,
    );
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: () => file,
      error: () => null,
      canProceed: state.contractName.isNotEmpty,
    );
  }

  void clearFile() {
    state = state.copyWith(
      selectedFile: () => null,
      canProceed: false,
    );
  }

  Future<bool> uploadContract() async {
    if (!state.canProceed) {
      state = state.copyWith(
        error: () => 'Please fill all required fields',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      final auditReport = await uploadContractUseCase.execute(state.selectedFile!);

      state = state.copyWith(
        isLoading: false,
        currentAuditReport: () => auditReport,
        error: () => null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to upload contract: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = AuditUploadState.initial();
  }
}

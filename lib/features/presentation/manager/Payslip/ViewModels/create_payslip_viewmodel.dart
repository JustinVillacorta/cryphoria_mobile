// lib/features/presentation/manager/Payslip/ViewModels/create_payslip_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/create_payslip_request.dart';
import '../../../../domain/usecases/payslip/create_payslip_use_case.dart';
import 'create_payslip_state.dart';

class CreatePayslipViewModel extends StateNotifier<CreatePayslipState> {
  final CreatePayslipUseCase createPayslipUseCase;

  CreatePayslipViewModel(this.createPayslipUseCase) : super(CreatePayslipState.initial());

  Future<void> createPayslip(CreatePayslipRequest request) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final payslip = await createPayslipUseCase(request);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdPayslip: payslip,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = CreatePayslipState.initial();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
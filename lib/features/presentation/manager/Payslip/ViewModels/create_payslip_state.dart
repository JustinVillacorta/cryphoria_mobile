// lib/features/presentation/manager/Payslip/ViewModels/create_payslip_state.dart

import '../../../../domain/entities/payslip.dart';

class CreatePayslipState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Payslip? createdPayslip;

  const CreatePayslipState({
    required this.isLoading,
    required this.isSuccess,
    this.error,
    this.createdPayslip,
  });

  factory CreatePayslipState.initial() {
    return CreatePayslipState(
      isLoading: false,
      isSuccess: false,
      error: null,
      createdPayslip: null,
    );
  }

  CreatePayslipState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Payslip? createdPayslip,
  }) {
    return CreatePayslipState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      createdPayslip: createdPayslip ?? this.createdPayslip,
    );
  }
}
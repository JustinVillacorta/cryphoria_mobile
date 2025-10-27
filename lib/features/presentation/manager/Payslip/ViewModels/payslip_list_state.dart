
import '../../../../domain/entities/payslip.dart';
import '../../../../domain/entities/create_payslip_request.dart';

class PayslipListState {
  final bool isLoading;
  final List<Payslip> payslips;
  final String? error;
  final PayslipFilter currentFilter;

  const PayslipListState({
    required this.isLoading,
    required this.payslips,
    this.error,
    required this.currentFilter,
  });

  factory PayslipListState.initial() {
    return PayslipListState(
      isLoading: false,
      payslips: [],
      error: null,
      currentFilter: PayslipFilter(),
    );
  }

  PayslipListState copyWith({
    bool? isLoading,
    List<Payslip>? payslips,
    String? error,
    PayslipFilter? currentFilter,
  }) {
    return PayslipListState(
      isLoading: isLoading ?? this.isLoading,
      payslips: payslips ?? this.payslips,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}
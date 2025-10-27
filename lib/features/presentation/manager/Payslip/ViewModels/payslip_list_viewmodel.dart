
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/create_payslip_request.dart';
import '../../../../domain/usecases/payslip/get_user_payslips_use_case.dart';
import 'payslip_list_state.dart';

class PayslipListViewModel extends StateNotifier<PayslipListState> {
  final GetUserPayslipsUseCase getUserPayslipsUseCase;

  PayslipListViewModel(this.getUserPayslipsUseCase) : super(PayslipListState.initial());

  Future<void> loadPayslips([PayslipFilter? filter]) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final payslips = await getUserPayslipsUseCase(filter ?? PayslipFilter());
      state = state.copyWith(
        isLoading: false,
        payslips: payslips,
        currentFilter: filter ?? PayslipFilter(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshPayslips() async {
    await loadPayslips(state.currentFilter);
  }

  void updateFilter(PayslipFilter filter) {
    state = state.copyWith(currentFilter: filter);
    loadPayslips(filter);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
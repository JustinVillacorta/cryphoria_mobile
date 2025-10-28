import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/cash_flow.dart';
import '../../../../domain/repositories/reports_repository.dart';


class CashFlowState {
  final bool isLoading;
  final CashFlowListResponse? cashFlowListResponse;
  final CashFlow? selectedCashFlow;
  final String? error;
  final bool hasData;

  CashFlowState({
    this.isLoading = false,
    this.cashFlowListResponse,
    this.selectedCashFlow,
    this.error,
    this.hasData = false,
  });

  CashFlowState copyWith({
    bool? isLoading,
    CashFlowListResponse? cashFlowListResponse,
    CashFlow? selectedCashFlow,
    String? error,
    bool? hasData,
  }) {
    return CashFlowState(
      isLoading: isLoading ?? this.isLoading,
      cashFlowListResponse: cashFlowListResponse ?? this.cashFlowListResponse,
      selectedCashFlow: selectedCashFlow ?? this.selectedCashFlow,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

class CashFlowViewModel extends StateNotifier<CashFlowState> {
  final ReportsRepository _reportsRepository;

  CashFlowViewModel(this._reportsRepository) : super(CashFlowState());

  Future<void> loadCashFlow() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashFlowListResponse = await _reportsRepository.getCashFlow();
      final selectedCashFlow = cashFlowListResponse.cashFlowStatements.isNotEmpty 
          ? cashFlowListResponse.cashFlowStatements.first 
          : null;

      state = state.copyWith(
        isLoading: false,
        cashFlowListResponse: cashFlowListResponse,
        selectedCashFlow: selectedCashFlow,
        hasData: cashFlowListResponse.cashFlowStatements.isNotEmpty,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasData: false,
      );
    }
  }

  void refresh() {
    loadCashFlow();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void selectCashFlow(CashFlow cashFlow) {
    state = state.copyWith(selectedCashFlow: cashFlow);
  }
}

final cashFlowViewModelProvider = StateNotifierProvider<CashFlowViewModel, CashFlowState>((ref) {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  return CashFlowViewModel(reportsRepository);
});
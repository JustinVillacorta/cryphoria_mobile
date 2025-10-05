import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/cash_flow.dart';
import '../../../../domain/repositories/reports_repository.dart';


// State classes
class CashFlowState {
  final bool isLoading;
  final CashFlow? cashFlow;
  final String? error;
  final bool hasData;

  CashFlowState({
    this.isLoading = false,
    this.cashFlow,
    this.error,
    this.hasData = false,
  });

  CashFlowState copyWith({
    bool? isLoading,
    CashFlow? cashFlow,
    String? error,
    bool? hasData,
  }) {
    return CashFlowState(
      isLoading: isLoading ?? this.isLoading,
      cashFlow: cashFlow ?? this.cashFlow,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

// View Model
class CashFlowViewModel extends StateNotifier<CashFlowState> {
  final ReportsRepository _reportsRepository;

  CashFlowViewModel(this._reportsRepository) : super(CashFlowState());

  Future<void> loadCashFlow() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final cashFlow = await _reportsRepository.getCashFlow();
      state = state.copyWith(
        isLoading: false,
        cashFlow: cashFlow,
        hasData: true,
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
}

// Provider
final cashFlowViewModelProvider = StateNotifierProvider<CashFlowViewModel, CashFlowState>((ref) {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  return CashFlowViewModel(reportsRepository);
});

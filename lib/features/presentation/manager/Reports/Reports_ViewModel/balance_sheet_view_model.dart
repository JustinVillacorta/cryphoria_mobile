import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/balance_sheet.dart';
import '../../../../domain/repositories/reports_repository.dart';


// State classes
class BalanceSheetState {
  final bool isLoading;
  final BalanceSheet? balanceSheet;
  final String? error;
  final bool hasData;

  BalanceSheetState({
    this.isLoading = false,
    this.balanceSheet,
    this.error,
    this.hasData = false,
  });

  BalanceSheetState copyWith({
    bool? isLoading,
    BalanceSheet? balanceSheet,
    String? error,
    bool? hasData,
  }) {
    return BalanceSheetState(
      isLoading: isLoading ?? this.isLoading,
      balanceSheet: balanceSheet ?? this.balanceSheet,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

// View Model
class BalanceSheetViewModel extends StateNotifier<BalanceSheetState> {
  final ReportsRepository _reportsRepository;

  BalanceSheetViewModel(this._reportsRepository) : super(BalanceSheetState());

  Future<void> loadBalanceSheet() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final balanceSheet = await _reportsRepository.getBalanceSheet();
      state = state.copyWith(
        isLoading: false,
        balanceSheet: balanceSheet,
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
    loadBalanceSheet();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final balanceSheetViewModelProvider = StateNotifierProvider<BalanceSheetViewModel, BalanceSheetState>((ref) {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  return BalanceSheetViewModel(reportsRepository);
});

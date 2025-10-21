import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/balance_sheet.dart';
import '../../../../domain/repositories/reports_repository.dart';


// State classes
class BalanceSheetState {
  final bool isLoading;
  final BalanceSheet? balanceSheet;
  final List<BalanceSheet>? balanceSheets;
  final BalanceSheet? selectedBalanceSheet;
  final String? error;
  final bool hasData;

  BalanceSheetState({
    this.isLoading = false,
    this.balanceSheet,
    this.balanceSheets,
    this.selectedBalanceSheet,
    this.error,
    this.hasData = false,
  });

  BalanceSheetState copyWith({
    bool? isLoading,
    BalanceSheet? balanceSheet,
    List<BalanceSheet>? balanceSheets,
    BalanceSheet? selectedBalanceSheet,
    String? error,
    bool? hasData,
  }) {
    return BalanceSheetState(
      isLoading: isLoading ?? this.isLoading,
      balanceSheet: balanceSheet ?? this.balanceSheet,
      balanceSheets: balanceSheets ?? this.balanceSheets,
      selectedBalanceSheet: selectedBalanceSheet ?? this.selectedBalanceSheet,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

// View Model
class BalanceSheetViewModel extends StateNotifier<BalanceSheetState> {
  final ReportsRepository _reportsRepository;

  BalanceSheetViewModel(this._reportsRepository) : super(BalanceSheetState());

  Future<void> loadAllBalanceSheets() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final balanceSheets = await _reportsRepository.getAllBalanceSheets();
      
      // Select the most recent balance sheet by default
      BalanceSheet? selectedSheet;
      if (balanceSheets.isNotEmpty) {
        selectedSheet = balanceSheets.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
      }
      
      state = state.copyWith(
        isLoading: false,
        balanceSheets: balanceSheets,
        selectedBalanceSheet: selectedSheet,
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
    loadAllBalanceSheets();
  }

  void selectBalanceSheet(BalanceSheet balanceSheet) {
    state = state.copyWith(selectedBalanceSheet: balanceSheet);
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

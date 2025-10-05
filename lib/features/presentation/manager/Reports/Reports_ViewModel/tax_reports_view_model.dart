import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/tax_report.dart';
import '../../../../domain/repositories/reports_repository.dart';


// State classes
class TaxReportsState {
  final bool isLoading;
  final TaxReport? taxReport;
  final String? error;
  final bool hasData;

  TaxReportsState({
    this.isLoading = false,
    this.taxReport,
    this.error,
    this.hasData = false,
  });

  TaxReportsState copyWith({
    bool? isLoading,
    TaxReport? taxReport,
    String? error,
    bool? hasData,
  }) {
    return TaxReportsState(
      isLoading: isLoading ?? this.isLoading,
      taxReport: taxReport ?? this.taxReport,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

// View Model
class TaxReportsViewModel extends StateNotifier<TaxReportsState> {
  final ReportsRepository _reportsRepository;

  TaxReportsViewModel(this._reportsRepository) : super(TaxReportsState());

  Future<void> loadTaxReports() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final taxReport = await _reportsRepository.getTaxReports();
      state = state.copyWith(
        isLoading: false,
        taxReport: taxReport,
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
    loadTaxReports();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final taxReportsViewModelProvider = StateNotifierProvider<TaxReportsViewModel, TaxReportsState>((ref) {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  return TaxReportsViewModel(reportsRepository);
});

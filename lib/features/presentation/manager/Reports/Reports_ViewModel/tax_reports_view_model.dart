import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/tax_report.dart';
import '../../../../domain/repositories/reports_repository.dart';


class TaxReportsState {
  final bool isLoading;
  final List<TaxReport> taxReports;
  final TaxReport? selectedReport;
  final String? error;
  final bool hasData;

  TaxReportsState({
    this.isLoading = false,
    this.taxReports = const [],
    this.selectedReport,
    this.error,
    this.hasData = false,
  });

  TaxReportsState copyWith({
    bool? isLoading,
    List<TaxReport>? taxReports,
    TaxReport? selectedReport,
    String? error,
    bool? hasData,
  }) {
    return TaxReportsState(
      isLoading: isLoading ?? this.isLoading,
      taxReports: taxReports ?? this.taxReports,
      selectedReport: selectedReport ?? this.selectedReport,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }

  TaxReport? get mostRecentReport {
    if (taxReports.isEmpty) return null;
    final sortedReports = List<TaxReport>.from(taxReports);
    sortedReports.sort((a, b) {
      final aTime = a.generatedAt ?? a.createdAt;
      final bTime = b.generatedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return sortedReports.first;
  }
}

class TaxReportsViewModel extends StateNotifier<TaxReportsState> {
  final ReportsRepository _reportsRepository;

  TaxReportsViewModel(this._reportsRepository) : super(TaxReportsState());

  Future<void> loadTaxReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final taxReports = await _reportsRepository.getTaxReports();
      final mostRecent = taxReports.isNotEmpty ? 
          taxReports.reduce((a, b) => 
              (a.generatedAt ?? a.createdAt).isAfter(b.generatedAt ?? b.createdAt) ? a : b) 
          : null;

      state = state.copyWith(
        isLoading: false,
        taxReports: taxReports,
        selectedReport: mostRecent,
        hasData: taxReports.isNotEmpty,
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

  void selectTaxReport(TaxReport report) {
    state = state.copyWith(selectedReport: report);
  }

  void refresh() {
    loadTaxReports();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final taxReportsViewModelProvider = StateNotifierProvider<TaxReportsViewModel, TaxReportsState>((ref) {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  return TaxReportsViewModel(reportsRepository);
});
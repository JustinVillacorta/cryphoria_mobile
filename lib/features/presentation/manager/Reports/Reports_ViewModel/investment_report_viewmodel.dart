import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/investment_report.dart';
import '../../../../domain/repositories/reports_repository.dart';

class InvestmentReportState {
  final List<InvestmentReport>? investmentReports;
  final InvestmentReport? selectedInvestmentReport;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const InvestmentReportState({
    this.investmentReports,
    this.selectedInvestmentReport,
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  InvestmentReportState copyWith({
    List<InvestmentReport>? investmentReports,
    InvestmentReport? selectedInvestmentReport,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return InvestmentReportState(
      investmentReports: investmentReports ?? this.investmentReports,
      selectedInvestmentReport: selectedInvestmentReport ?? this.selectedInvestmentReport,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool get hasData => investmentReports != null && investmentReports!.isNotEmpty;
  bool get hasError => error != null;
}

class InvestmentReportViewModel extends StateNotifier<InvestmentReportState> {
  final ReportsRepository _reportsRepository;

  InvestmentReportViewModel(this._reportsRepository) : super(const InvestmentReportState());

  Future<void> loadInvestmentReports() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      print("🔄 InvestmentReportViewModel: Loading investment reports...");
      final investmentReports = await _reportsRepository.getInvestmentReports();
      print("📥 InvestmentReportViewModel: Received ${investmentReports.length} investment reports");

      // Select the most recent investment report by default
      InvestmentReport? selectedReport;
      if (investmentReports.isNotEmpty) {
        selectedReport = investmentReports.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
      }

      state = state.copyWith(
        investmentReports: investmentReports,
        selectedInvestmentReport: selectedReport,
        isLoading: false,
        error: null,
      );

      print("✅ InvestmentReportViewModel: Successfully loaded investment reports");
    } catch (e) {
      print("❌ InvestmentReportViewModel: Error loading investment reports: $e");
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      print("🔄 InvestmentReportViewModel: Refreshing investment reports...");
      final investmentReports = await _reportsRepository.getInvestmentReports();
      print("📥 InvestmentReportViewModel: Refreshed ${investmentReports.length} investment reports");

      // Select the most recent investment report by default
      InvestmentReport? selectedReport;
      if (investmentReports.isNotEmpty) {
        selectedReport = investmentReports.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
      }

      state = state.copyWith(
        investmentReports: investmentReports,
        selectedInvestmentReport: selectedReport,
        isRefreshing: false,
        error: null,
      );

      print("✅ InvestmentReportViewModel: Successfully refreshed investment reports");
    } catch (e) {
      print("❌ InvestmentReportViewModel: Error refreshing investment reports: $e");
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  void selectInvestmentReport(InvestmentReport investmentReport) {
    state = state.copyWith(selectedInvestmentReport: investmentReport);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

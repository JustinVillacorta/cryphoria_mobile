import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/income_statement.dart';
import '../../../../domain/repositories/reports_repository.dart';

class IncomeStatementState {
  final List<IncomeStatement>? incomeStatements;
  final IncomeStatement? selectedIncomeStatement;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const IncomeStatementState({
    this.incomeStatements,
    this.selectedIncomeStatement,
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  IncomeStatementState copyWith({
    List<IncomeStatement>? incomeStatements,
    IncomeStatement? selectedIncomeStatement,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return IncomeStatementState(
      incomeStatements: incomeStatements ?? this.incomeStatements,
      selectedIncomeStatement: selectedIncomeStatement ?? this.selectedIncomeStatement,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool get hasData => incomeStatements != null && incomeStatements!.isNotEmpty;
  bool get hasError => error != null;
}

class IncomeStatementViewModel extends StateNotifier<IncomeStatementState> {
  final ReportsRepository _reportsRepository;

  IncomeStatementViewModel(this._reportsRepository) : super(const IncomeStatementState());

  Future<void> loadIncomeStatements() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final incomeStatements = await _reportsRepository.getIncomeStatements();

      IncomeStatement? selectedStatement;
      if (incomeStatements.isNotEmpty) {
        selectedStatement = incomeStatements.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
      }

      state = state.copyWith(
        incomeStatements: incomeStatements,
        selectedIncomeStatement: selectedStatement,
        isLoading: false,
        error: null,
      );

    } catch (e) {
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
      final incomeStatements = await _reportsRepository.getIncomeStatements();

      IncomeStatement? selectedStatement;
      if (incomeStatements.isNotEmpty) {
        selectedStatement = incomeStatements.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
      }

      state = state.copyWith(
        incomeStatements: incomeStatements,
        selectedIncomeStatement: selectedStatement,
        isRefreshing: false,
        error: null,
      );

    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  void selectIncomeStatement(IncomeStatement incomeStatement) {
    state = state.copyWith(selectedIncomeStatement: incomeStatement);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
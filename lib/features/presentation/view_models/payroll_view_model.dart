import 'package:cryphoria_mobile/features/domain/entities/payroll_period.dart';
import 'package:cryphoria_mobile/features/domain/usecases/payroll/create_payroll_period_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/payroll/get_payroll_analytics_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/payroll/get_payroll_periods_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/payroll/process_payroll_period_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/payroll/update_payroll_entry_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayrollState {
  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final List<PayrollEntry> selectedPeriodEntries;
  final PayrollSummary? currentSummary;
  final Map<String, dynamic>? analytics;
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const PayrollState({
    this.periods = const [],
    this.selectedPeriod,
    this.selectedPeriodEntries = const [],
    this.currentSummary,
    this.analytics,
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  PayrollState copyWith({
    List<PayrollPeriod>? periods,
    PayrollPeriod? selectedPeriod,
    List<PayrollEntry>? selectedPeriodEntries,
    PayrollSummary? currentSummary,
    Map<String, dynamic>? analytics,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return PayrollState(
      periods: periods ?? this.periods,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedPeriodEntries: selectedPeriodEntries ?? this.selectedPeriodEntries,
      currentSummary: currentSummary ?? this.currentSummary,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class PayrollViewModel extends StateNotifier<PayrollState> {
  final GetPayrollPeriodsUseCase getPayrollPeriodsUseCase;
  final CreatePayrollPeriodUseCase createPayrollPeriodUseCase;
  final ProcessPayrollPeriodUseCase processPayrollPeriodUseCase;
  final UpdatePayrollEntryUseCase updatePayrollEntryUseCase;
  final GetPayrollAnalyticsUseCase getPayrollAnalyticsUseCase;

  PayrollViewModel({
    required this.getPayrollPeriodsUseCase,
    required this.createPayrollPeriodUseCase,
    required this.processPayrollPeriodUseCase,
    required this.updatePayrollEntryUseCase,
    required this.getPayrollAnalyticsUseCase,
  }) : super(const PayrollState());

  /// Load all payroll periods
  Future<void> loadPayrollPeriods() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final periods = await getPayrollPeriodsUseCase.execute();
      state = state.copyWith(
        periods: periods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new payroll period
  Future<bool> createPayrollPeriod(CreatePayrollPeriodRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newPeriod = await createPayrollPeriodUseCase.execute(request);
      
      // Add the new period to the list
      final updatedPeriods = [...state.periods, newPeriod];
      
      state = state.copyWith(
        periods: updatedPeriods,
        isLoading: false,
        successMessage: 'Payroll period created successfully',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Select a payroll period and load its details
  void selectPayrollPeriod(PayrollPeriod period) {
    state = state.copyWith(
      selectedPeriod: period,
      selectedPeriodEntries: period.entries,
      currentSummary: period.summary,
    );
  }

  /// Process a payroll period
  Future<bool> processPayrollPeriod(String periodId) async {
    state = state.copyWith(isProcessing: true, error: null);
    
    try {
      final processedPeriod = await processPayrollPeriodUseCase.execute(periodId);
      
      // Update the period in the list
      final updatedPeriods = state.periods.map((period) {
        return period.periodId == periodId ? processedPeriod : period;
      }).toList();
      
      state = state.copyWith(
        periods: updatedPeriods,
        selectedPeriod: processedPeriod,
        selectedPeriodEntries: processedPeriod.entries,
        currentSummary: processedPeriod.summary,
        isProcessing: false,
        successMessage: 'Payroll period processed successfully',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update a payroll entry
  Future<bool> updatePayrollEntry(UpdatePayrollEntryRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedEntry = await updatePayrollEntryUseCase.execute(request);
      
      // Update the entry in the current list
      final updatedEntries = state.selectedPeriodEntries.map((entry) {
        return entry.entryId == request.entryId ? updatedEntry : entry;
      }).toList();
      
      state = state.copyWith(
        selectedPeriodEntries: updatedEntries,
        isLoading: false,
        successMessage: 'Payroll entry updated successfully',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Load payroll analytics
  Future<void> loadPayrollAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final analytics = await getPayrollAnalyticsUseCase.execute(
        startDate: startDate,
        endDate: endDate,
        department: department,
      );
      
      state = state.copyWith(
        analytics: analytics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  /// Get periods by status
  List<PayrollPeriod> getPeriodsByStatus(PayrollPeriodStatus status) {
    return state.periods.where((period) => period.status == status).toList();
  }

  /// Get total amount for a specific status
  double getTotalAmountByStatus(PayrollPeriodStatus status) {
    return getPeriodsByStatus(status)
        .fold(0.0, (sum, period) => sum + period.totalAmount);
  }

  /// Get pending entries count
  int get pendingEntriesCount {
    return state.selectedPeriodEntries
        .where((entry) => entry.status == PayrollEntryStatus.pending)
        .length;
  }

  /// Get completed entries count
  int get completedEntriesCount {
    return state.selectedPeriodEntries
        .where((entry) => entry.status == PayrollEntryStatus.paid)
        .length;
  }

  /// Check if current period can be processed
  bool get canProcessCurrentPeriod {
    return state.selectedPeriod?.canProcess ?? false;
  }

  /// Get current period total pending amount
  double get currentPeriodPendingAmount {
    return state.selectedPeriod?.totalPending ?? 0.0;
  }

  /// Get current period total paid amount
  double get currentPeriodPaidAmount {
    return state.selectedPeriod?.totalPaid ?? 0.0;
  }
}

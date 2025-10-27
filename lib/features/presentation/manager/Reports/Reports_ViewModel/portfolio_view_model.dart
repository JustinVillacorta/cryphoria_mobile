import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/portfolio.dart';
import '../../../../domain/repositories/reports_repository.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';

class PortfolioState {
  final bool isLoading;
  final Portfolio? portfolio;
  final String? error;
  final bool hasData;

  const PortfolioState({
    required this.isLoading,
    this.portfolio,
    this.error,
    required this.hasData,
  });

  factory PortfolioState.initial() {
    return const PortfolioState(
      isLoading: false,
      hasData: false,
    );
  }

  PortfolioState copyWith({
    bool? isLoading,
    Portfolio? portfolio,
    String? error,
    bool? hasData,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      portfolio: portfolio ?? this.portfolio,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
    );
  }
}

class PortfolioViewModel extends StateNotifier<PortfolioState> {
  final ReportsRepository _reportsRepository;

  PortfolioViewModel(this._reportsRepository) : super(PortfolioState.initial());

  Future<void> loadPortfolioValue() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final portfolio = await _reportsRepository.getPortfolioValue();
      state = state.copyWith(
        isLoading: false,
        portfolio: portfolio,
        hasData: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadPortfolioValue();
  }
}

final portfolioViewModelProvider = StateNotifierProvider<PortfolioViewModel, PortfolioState>((ref) {
  return PortfolioViewModel(ref.watch(reportsRepositoryProvider));
});
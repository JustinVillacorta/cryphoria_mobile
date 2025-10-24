// lib/features/presentation/providers/smart_invest_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/smart_invest_remote_data_source.dart';
import '../../data/repositories/smart_invest_repository_impl.dart';
import '../../data/services/smart_invest_service.dart';
import '../../domain/usecases/smart_invest/send_investment_usecase.dart';
import '../../domain/usecases/smart_invest/upsert_address_book_usecase.dart';
import '../../domain/usecases/smart_invest/get_address_book_list_usecase.dart';
import '../../domain/usecases/smart_invest/delete_address_book_usecase.dart';
import '../../domain/usecases/smart_invest/get_investment_statistics_usecase.dart';
import '../../domain/entities/smart_invest.dart';
import '../../domain/entities/investment_report.dart';
import '../../../dependency_injection/riverpod_providers.dart';

// Data Source Provider
final smartInvestRemoteDataSourceProvider = Provider<SmartInvestRemoteDataSource>((ref) {
  return SmartInvestRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
  );
});

// Repository Provider
final smartInvestRepositoryProvider = Provider<SmartInvestRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(smartInvestRemoteDataSourceProvider);
  return SmartInvestRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Smart Invest Service Provider
final smartInvestServiceProvider = Provider<SmartInvestService>((ref) {
  return SmartInvestService(
    walletService: ref.watch(walletServiceProvider),
  );
});

// Use Case Providers
final sendInvestmentUseCaseProvider = Provider<SendInvestmentUseCase>((ref) {
  final repository = ref.watch(smartInvestRepositoryProvider);
  return SendInvestmentUseCase(repository: repository);
});

final upsertAddressBookUseCaseProvider = Provider<UpsertAddressBookUseCase>((ref) {
  final repository = ref.watch(smartInvestRepositoryProvider);
  return UpsertAddressBookUseCase(repository: repository);
});

final getAddressBookListUseCaseProvider = Provider<GetAddressBookListUseCase>((ref) {
  final repository = ref.watch(smartInvestRepositoryProvider);
  return GetAddressBookListUseCase(repository: repository);
});

final deleteAddressBookUseCaseProvider = Provider<DeleteAddressBookUseCase>((ref) {
  final repository = ref.watch(smartInvestRepositoryProvider);
  return DeleteAddressBookUseCase(repository: repository);
});

final getInvestmentStatisticsUseCaseProvider = Provider<GetInvestmentStatisticsUseCase>((ref) {
  final remoteDataSource = ref.watch(smartInvestRemoteDataSourceProvider);
  return GetInvestmentStatisticsUseCase(remoteDataSource: remoteDataSource);
});

// State Providers
class SmartInvestState {
  final bool isLoading;
  final String? error;
  final SmartInvestResponse? lastInvestment;
  final List<AddressBookEntry> addressBookEntries;
  final bool isAddressBookLoading;
  final String? addressBookError;
  final InvestmentStatistics? investmentStatistics;
  final bool isStatisticsLoading;
  final String? statisticsError;

  SmartInvestState({
    this.isLoading = false,
    this.error,
    this.lastInvestment,
    this.addressBookEntries = const [],
    this.isAddressBookLoading = false,
    this.addressBookError,
    this.investmentStatistics,
    this.isStatisticsLoading = false,
    this.statisticsError,
  });

  SmartInvestState copyWith({
    bool? isLoading,
    String? error,
    SmartInvestResponse? lastInvestment,
    List<AddressBookEntry>? addressBookEntries,
    bool? isAddressBookLoading,
    String? addressBookError,
    InvestmentStatistics? investmentStatistics,
    bool? isStatisticsLoading,
    String? statisticsError,
  }) {
    return SmartInvestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastInvestment: lastInvestment ?? this.lastInvestment,
      addressBookEntries: addressBookEntries ?? this.addressBookEntries,
      isAddressBookLoading: isAddressBookLoading ?? this.isAddressBookLoading,
      addressBookError: addressBookError,
      investmentStatistics: investmentStatistics ?? this.investmentStatistics,
      isStatisticsLoading: isStatisticsLoading ?? this.isStatisticsLoading,
      statisticsError: statisticsError,
    );
  }
}

class SmartInvestNotifier extends StateNotifier<SmartInvestState> {
  final SmartInvestService smartInvestService;
  final UpsertAddressBookUseCase upsertAddressBookUseCase;
  final GetAddressBookListUseCase getAddressBookListUseCase;
  final DeleteAddressBookUseCase deleteAddressBookUseCase;
  final GetInvestmentStatisticsUseCase getInvestmentStatisticsUseCase;

  SmartInvestNotifier({
    required this.smartInvestService,
    required this.upsertAddressBookUseCase,
    required this.getAddressBookListUseCase,
    required this.deleteAddressBookUseCase,
    required this.getInvestmentStatisticsUseCase,
  }) : super(SmartInvestState());

  Future<SmartInvestResponse?> sendInvestment(SmartInvestRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('📤 SmartInvestNotifier.sendInvestment called');
      print('📋 Recipient: ${request.toAddress}');
      print('📋 Amount: ${request.amount}');
      print('📋 Investor: ${request.investorName}');
      print('📋 Description: ${request.description}');
      
      // Use SmartInvestService which calls WalletService.sendEth
      final response = await smartInvestService.sendInvestment(
        recipientAddress: request.toAddress,
        amount: request.amount,
        investorName: request.investorName,
        description: request.description,
        category: 'INVESTMENT', // Default category for smart investments
      );
      
      print('✅ SmartInvestNotifier.sendInvestment successful: ${response.data.transactionHash}');
      state = state.copyWith(
        isLoading: false,
        lastInvestment: response,
        error: null,
      );
      
      return response;
    } catch (e) {
      print('❌ SmartInvestNotifier.sendInvestment failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> upsertAddressBookEntry(AddressBookUpsertRequest request) async {
    state = state.copyWith(isAddressBookLoading: true, addressBookError: null);
    
    try {
      await upsertAddressBookUseCase.execute(request);
      // Refresh address book list after upsert
      final response = await getAddressBookListUseCase.execute();
      print('📋 Upsert: Got ${response.data.length} address book entries');
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookEntries: List<AddressBookEntry>.from(response.data),
        addressBookError: null,
      );
      print('📋 Upsert: State updated with ${state.addressBookEntries.length} entries');
    } catch (e) {
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookError: e.toString(),
      );
    }
  }

  Future<void> getAddressBookList() async {
    state = state.copyWith(isAddressBookLoading: true, addressBookError: null);
    
    try {
      final response = await getAddressBookListUseCase.execute();
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookEntries: List<AddressBookEntry>.from(response.data),
        addressBookError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookError: e.toString(),
      );
    }
  }

  Future<void> deleteAddressBookEntry(String address) async {
    state = state.copyWith(isAddressBookLoading: true, addressBookError: null);
    
    try {
      await deleteAddressBookUseCase.execute(address);
      // Refresh address book list after deletion
      final response = await getAddressBookListUseCase.execute();
      print('📋 Delete: Got ${response.data.length} address book entries');
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookEntries: List<AddressBookEntry>.from(response.data),
        addressBookError: null,
      );
      print('📋 Delete: State updated with ${state.addressBookEntries.length} entries');
    } catch (e) {
      state = state.copyWith(
        isAddressBookLoading: false,
        addressBookError: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearAddressBookError() {
    state = state.copyWith(addressBookError: null);
  }

  Future<void> getInvestmentStatistics() async {
    state = state.copyWith(isStatisticsLoading: true, statisticsError: null);
    
    try {
      final statistics = await getInvestmentStatisticsUseCase.execute();
      state = state.copyWith(
        isStatisticsLoading: false,
        investmentStatistics: statistics,
        statisticsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isStatisticsLoading: false,
        statisticsError: e.toString(),
      );
    }
  }

  void clearStatisticsError() {
    state = state.copyWith(statisticsError: null);
  }
}

final smartInvestNotifierProvider = StateNotifierProvider<SmartInvestNotifier, SmartInvestState>((ref) {
  final smartInvestService = ref.watch(smartInvestServiceProvider);
  final upsertAddressBookUseCase = ref.watch(upsertAddressBookUseCaseProvider);
  final getAddressBookListUseCase = ref.watch(getAddressBookListUseCaseProvider);
  final deleteAddressBookUseCase = ref.watch(deleteAddressBookUseCaseProvider);
  final getInvestmentStatisticsUseCase = ref.watch(getInvestmentStatisticsUseCaseProvider);
  
  return SmartInvestNotifier(
    smartInvestService: smartInvestService,
    upsertAddressBookUseCase: upsertAddressBookUseCase,
    getAddressBookListUseCase: getAddressBookListUseCase,
    deleteAddressBookUseCase: deleteAddressBookUseCase,
    getInvestmentStatisticsUseCase: getInvestmentStatisticsUseCase,
  );
});

import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/domain/usecases/EmployeeHome/employee_home_usecase.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWalletService extends Mock implements WalletService {}

class _MockTransactionsDataSource extends Mock
    implements TransactionsDataSource {}

class _MockGetEmployeeDashboardData extends Mock
    implements GetEmployeeDashboardData {}

void main() {
  late HomeEmployeeNotifier notifier;
  late _MockWalletService walletService;
  late _MockTransactionsDataSource transactionsDataSource;
  late _MockGetEmployeeDashboardData dashboardData;

  setUp(() {
    walletService = _MockWalletService();
    transactionsDataSource = _MockTransactionsDataSource();
    dashboardData = _MockGetEmployeeDashboardData();
    notifier = HomeEmployeeNotifier(
      walletService: walletService,
      transactionsDataSource: transactionsDataSource,
      getEmployeeDashboardData: dashboardData,
    );
  });

  test('initial state is expected defaults', () {
    final state = notifier.state;
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(state.employeeName, 'Anna');
    expect(state.selectedCurrency, 'PHP');
  });

  test('clearError resets error flags', () {
    notifier.state = notifier.state.copyWith(
      hasError: true,
      errorMessage: () => 'oops',
    );

    notifier.clearError();

    expect(notifier.state.hasError, isFalse);
    expect(notifier.state.errorMessage, isEmpty);
  });

  test('changeCurrency updates selected currency when wallet exists', () {
    notifier.state = notifier.state.copyWith(
      wallet: Wallet(
        id: '1',
        name: 'MetaMask',
        balance: 1.0,
      ),
      selectedCurrency: 'PHP',
    );

    notifier.changeCurrency('USD');

    expect(notifier.state.selectedCurrency, 'USD');
  });
}

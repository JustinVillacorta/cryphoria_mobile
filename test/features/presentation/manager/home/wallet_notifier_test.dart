import 'package:cryphoria_mobile/features/data/data_sources/eth_transaction_data_source.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/domain/entities/wallet.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_ViewModel/home_Viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWalletService extends Mock implements WalletService {}

class _MockTransactionsDataSource extends Mock
    implements EthTransactionDataSource {}

void main() {
  late WalletNotifier notifier;
  late _MockWalletService walletService;
  late _MockTransactionsDataSource transactionSource;

  setUp(() {
    walletService = _MockWalletService();
    transactionSource = _MockTransactionsDataSource();
    when(() => walletService.hasStoredWallet()).thenAnswer((_) async => false);
    when(() => transactionSource.getAllTransactions(
          userWallets: any<List<Wallet>>(named: 'userWallets'),
          knownReceivedHashes:
              any<dynamic>(named: 'knownReceivedHashes'),
          limit: any<int>(named: 'limit'),
        )).thenAnswer((_) async => []);
    notifier = WalletNotifier(
      walletService: walletService,
      ethTransactionDataSource: transactionSource,
    );
  });

  test('initial state is correct', () {
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.error, isNull);
    expect(notifier.state.wallet, isNull);
    expect(notifier.state.transactions, isEmpty);
  });

  test('clearError resets error', () {
    notifier.state = notifier.state.copyWith(error: () => 'oops');
    notifier.clearError();
    expect(notifier.state.error, isNull);
  });

  test('connect updates wallet state', () async {
    final wallet = Wallet(
      id: '1',
      name: 'MetaMask',
      private_key: 'key',
      balance: 1.0,
    );
    when(() => walletService.connectWallet(any(),
            endpoint: any(named: 'endpoint'),
            walletName: any(named: 'walletName'),
            walletType: any(named: 'walletType')))
        .thenAnswer((_) async => wallet);
    when(() => transactionSource.getAllTransactions(
          userWallets: any<List<Wallet>>(named: 'userWallets'),
          knownReceivedHashes:
              any<dynamic>(named: 'knownReceivedHashes'),
          limit: any<int>(named: 'limit'),
        )).thenAnswer((_) async => []);

    await notifier.connect('0xabc');

    expect(notifier.state.wallet, isNotNull);
    expect(notifier.state.wallet!.name, 'MetaMask');
  });
}

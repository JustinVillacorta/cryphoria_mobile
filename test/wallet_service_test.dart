// import 'package:flutter_test/flutter_test.dart';
// import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
// import 'package:cryphoria_mobile/features/data/services/currency_conversion_service.dart';
// import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
// import 'private_key_storage_test.dart';
// import 'package:dio/dio.dart';

// class FakeCurrencyService extends CurrencyConversionService {
//   FakeCurrencyService() : super(dio: Dio());
  
//   @override
//   Future<Map<String, double>> getETHRates() async {
//     return {
//       'php': 200000.0,
//       'usd': 3200.0,
//     };
//   }
// }

// class FakeRemote extends WalletRemoteDataSource {
//   FakeRemote() : super();

//   @override
//   Future<Map<String, dynamic>> registerWallet({
//     required String endpoint,
//     required String privateKey,
//     required String walletName,
//     required String walletType,
//   }) async {
//     return {
//       'wallet_id': 'test_wallet_id',
//       'name': walletName,
//       'wallet_type': walletType,
//       'balances': {
//         'ETH': {
//           'balance': '5.0'
//         }
//       }
//     };
//   }
  
//   @override
//   Future<Map<String, dynamic>> reconnectWallet({
//     required String privateKey,
//   }) async {
//     return {
//       'wallet_id': 'test_wallet_id',
//       'name': 'Stored Wallet',
//       'wallet_type': 'MetaMask',
//       'balances': {
//         'ETH': {
//           'balance': '5.0'
//         }
//       }
//     };
//   }
  
//   @override
//   Future<double> getBalance(String walletAddress) async {
//     return 5.0;
//   }
// }

// class NotFoundRemote extends WalletRemoteDataSource {
//   NotFoundRemote() : super();

//   @override
//   Future<Map<String, dynamic>> registerWallet({
//     required String endpoint,
//     required String privateKey,
//     required String walletName,
//     required String walletType,
//   }) async {
//     throw WalletNotFoundException();
//   }

//   @override
//   Future<Map<String, dynamic>> reconnectWallet({
//     required String privateKey,
//   }) async {
//     throw WalletNotFoundException();
//   }

//   @override
//   Future<double> getBalance(String walletAddress) async {
//     throw WalletNotFoundException();
//   }
// }

// void main() {
//   test('connect stores key and returns wallet', () async {
//     const key =
//         '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
//     final service = WalletService(
//       remoteDataSource: FakeRemote(),
//       storage: MemoryStorage(),
//       currencyService: FakeCurrencyService(),
//     );
//     final wallet = await service.connectWallet(
//       key,
//       endpoint: 'connect_trust_wallet/',
//       walletName: 'Mobile Wallet',
//       walletType: 'Trust Wallet',
//     );
//     expect(wallet.private_key, key);
//     expect(wallet.balance, 5.0);
//   });

//   test('reconnect uses stored key', () async {
//     const key =
//         '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
//     final storage = MemoryStorage();
//     await storage.saveKey(key);
//     final service = WalletService(
//       remoteDataSource: FakeRemote(),
//       storage: storage,
//       currencyService: FakeCurrencyService(),
//     );
//     final wallet = await service.reconnect();
//     expect(wallet?.balance, 5.0);
//   });

//   test('reconnect returns null when wallet missing', () async {
//     const key =
//         '0x8f2a559490cc2a7ab61c32ed3d8060216ee02e4960a83f97bde6ceb39d4b4d5e';
//     final storage = MemoryStorage();
//     await storage.saveKey(key);
//     final service = WalletService(
//       remoteDataSource: NotFoundRemote(),
//       storage: storage,
//       currencyService: FakeCurrencyService(),
//     );
//     final wallet = await service.reconnect();
//     expect(wallet, isNull);
//   });
// }
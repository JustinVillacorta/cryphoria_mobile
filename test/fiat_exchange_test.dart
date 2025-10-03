import 'package:flutter_test/flutter_test.dart';
import '../lib/features/data/data_sources/walletRemoteDataSource.dart';
import '../lib/features/data/services/wallet_service.dart';
import '../lib/features/data/services/currency_conversion_service.dart';

void main() {
  group('Fiat Exchange Tests', () {
    late WalletRemoteDataSource walletDataSource;
    late CurrencyConversionService currencyService;
    late WalletService walletService;

    setUp(() {
      walletDataSource = WalletRemoteDataSource();
      currencyService = CurrencyConversionService();
      walletService = WalletService(
        remoteDataSource: walletDataSource,
        currencyService: currencyService,
      );
    });

    test('should have convertCryptoToFiat method in WalletService', () {
      expect(walletService.convertCryptoToFiat, isA<Function>());
    });

    test('should have convertCryptoToFiat method in CurrencyConversionService', () {
      expect(currencyService.convertCryptoToFiat, isA<Function>());
    });

    test('should have convertCryptoToFiat method in WalletRemoteDataSource', () {
      expect(walletDataSource.convertCryptoToFiat, isA<Function>());
    });

    test('should accept correct parameters for conversion', () {
      // This test verifies the method signature is correct
      expect(() {
        walletService.convertCryptoToFiat(
          value: '5',
          from: 'ETH',
          to: 'PHP',
        );
      }, returnsNormally);
    });

    test('should handle different currency pairs', () {
      // Test various currency combinations
      final testCases = [
        {'value': '1', 'from': 'ETH', 'to': 'USD'},
        {'value': '2.5', 'from': 'ETH', 'to': 'PHP'},
        {'value': '10', 'from': 'BTC', 'to': 'EUR'},
      ];

      for (final testCase in testCases) {
        expect(() {
          walletService.convertCryptoToFiat(
            value: testCase['value']!,
            from: testCase['from']!,
            to: testCase['to']!,
          );
        }, returnsNormally);
      }
    });
  });
}

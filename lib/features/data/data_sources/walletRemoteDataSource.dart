import 'package:dio/dio.dart';
import '../../domain/entities/wallet.dart';

class WalletNotFoundException implements Exception {
  final String message;

  WalletNotFoundException([this.message = 'Wallet not found']);

  @override
  String toString() => 'WalletNotFoundException: ' + message;
}

class WalletRemoteDataSource {
  final String baseUrl;
  final Dio dio;

  WalletRemoteDataSource({
    this.baseUrl = "http://localhost:8000/api/wallets/",
    Dio? dio,
  }) : dio = dio ?? Dio();

  Future<List<Wallet>> fetchWallets() async {
    try {
      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      final walletsJson = response.data["data"]["wallets"] as List;
      return walletsJson.map((json) => Wallet.fromJson(json)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message;
      throw Exception("Failed to fetch wallets: ${e.response?.statusCode} $msg");
    }
  }

  Future<Wallet> createWallet(Wallet wallet) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: {
          "wallet_name": wallet.name,
          // NOTE: This looks wrong; `wallet.address` is not a private key.
          // Confirm backend contract before sending private keys to server.
          "private_key": wallet.private_key,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      return Wallet.fromJson(response.data["data"]);
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message;
      throw Exception("Failed to add wallet: ${e.response?.statusCode} $msg");
    }
  }

  Future<void> registerWallet({
    required String endpoint,
    required String privateKey,
    required String walletName,
    required String walletType,
  }) async {
    final url = '$baseUrl$endpoint';
    try {
      await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          // Server expects the private key
          'private_key': privateKey,
          'wallet_name': walletName,
          'wallet_type': walletType,
        },
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to connect wallet: $status $body');
    }
  }

  Future<double> getBalance(String walletAddress) async {
    final url = '${baseUrl}get_specific_wallet_balance/';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          'wallet_address': walletAddress,
        },
      );
      final balance = response.data['data']?['wallet']?['balances']?['ETH']?['balance'] ?? 0;
      return double.tryParse(balance.toString()) ?? 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        throw WalletNotFoundException();
      }
      final msg = e.response?.data ?? e.message;
      throw Exception('Failed to load balance: ${e.response?.statusCode} $msg');
    }
  }
}
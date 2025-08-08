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
    } on DioError catch (e) {
      throw Exception("Failed to fetch wallets: ${e.response?.statusCode}");
    }
  }

  Future<Wallet> createWallet(Wallet wallet) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: {
          "name": wallet.name,
          "address": wallet.address,
          // Include additional fields if needed.
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      return Wallet.fromJson(response.data["data"]);
    } on DioError catch (e) {
      throw Exception("Failed to add wallet: ${e.response?.statusCode}");
    }
  }

  Future<void> registerWallet({
    required String endpoint,
    required String walletAddress,
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
          'address': walletAddress,
          'wallet_name': walletName,
          'wallet_type': walletType,
        },
      );
    } on DioError catch (e) {
      throw Exception('Failed to connect wallet: ${e.response?.statusCode}');
    }
  }

  Future<double> getBalance(String walletAddress) async {
    final url = '${baseUrl}get_wallet_balance/';
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        queryParameters: {
          'wallet_address': walletAddress,
        },
      );
      final balance =
          response.data['balance'] ?? response.data['data']?['balance'] ?? 0;
      return (balance as num).toDouble();
    } on DioError catch (e) {
      if (e.response?.statusCode == 403) {
        throw WalletNotFoundException();
      }
      throw Exception('Failed to load balance: ${e.response?.statusCode}');
    }
  }
}

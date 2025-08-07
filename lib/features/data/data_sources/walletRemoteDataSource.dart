import 'package:dio/dio.dart';
import '../../domain/entities/wallet.dart';

class WalletRemoteDataSource {
  final String baseUrl;
  String token;
  final Dio dio;

  WalletRemoteDataSource({
    this.baseUrl = "http://localhost:8000/api/wallets/",
    required this.token,
    Dio? dio,
  }) : dio = dio ?? Dio();

  Future<List<Wallet>> fetchWallets() async {
    try {
      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {
            "Authorization": "Token $token",
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
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
      );
      return Wallet.fromJson(response.data["data"]);
    } on DioError catch (e) {
      throw Exception("Failed to add wallet: ${e.response?.statusCode}");
    }
  }

  Future<String> connectWithPrivateKey({
    required String endpoint,
    required String privateKey,
    required String walletName,
  }) async {
    final url = '$baseUrl$endpoint';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          'private_key': privateKey,
          'wallet_name': walletName,
        },
      );
      return response.data['wallet_address'] as String;
    } on DioError catch (e) {
      throw Exception('Failed to connect wallet: ${e.response?.statusCode}');
    }
  }

  Future<String> reconnectWithPrivateKey(String privateKey) async {
    final url = '${baseUrl}reconnect_wallet_with_private_key/';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          'private_key': privateKey,
        },
      );
      return response.data['wallet_address'] as String;
    } on DioError catch (e) {
      throw Exception('Failed to reconnect wallet: ${e.response?.statusCode}');
    }
  }

  Future<double> getBalance(String walletAddress) async {
    final url = '${baseUrl}get_specific_wallet_balance/';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          'wallet_address': walletAddress,
        },
      );
      final balance =
          response.data['balance'] ?? response.data['data']?['balance'] ?? 0;
      return (balance as num).toDouble();
    } on DioError catch (e) {
      throw Exception('Failed to load balance: ${e.response?.statusCode}');
    }
  }
}

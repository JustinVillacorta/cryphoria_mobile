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

  /// Connect wallet using private key and return wallet data
  Future<Map<String, dynamic>> registerWallet({
    required String endpoint,
    required String privateKey,
    required String walletName,
    required String walletType,
  }) async {
    // Use the documented connect_wallet_with_private_key endpoint
    // regardless of the wallet type passed from the UI
    final url = '${baseUrl}connect_wallet_with_private_key/';
    try {
      final response = await dio.post(
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
      
      // Return the wallet data from backend response
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to connect wallet: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to connect wallet: $status $body');
    }
  }

  /// Reconnect to an existing wallet (for device switching) and return wallet data
  Future<Map<String, dynamic>> reconnectWallet({
    required String privateKey,
  }) async {
    final url = '${baseUrl}reconnect_wallet_with_private_key/';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          'private_key': privateKey,
        },
      );
      
      // Return the wallet data from backend response
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to reconnect wallet: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to reconnect wallet: $status $body');
    }
  }

  Future<double> getBalance(String walletAddress) async {
    // Use the WalletViewSet's get_wallet_balance endpoint
    final url = '${baseUrl}get_wallet_balance/';
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      
      // Backend returns all wallets for the authenticated user
      final wallets = response.data['data']?['wallets'] as List? ?? [];
      
      // Find the specific wallet by address
      for (final wallet in wallets) {
        if (wallet['address']?.toLowerCase() == walletAddress.toLowerCase()) {
          final balance = wallet['balances']?['ETH']?['balance'] ?? 0;
          return double.tryParse(balance.toString()) ?? 0;
        }
      }
      
      // If wallet not found, return 0 (or throw WalletNotFoundException)
      return 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        throw WalletNotFoundException();
      }
      final msg = e.response?.data ?? e.message;
      throw Exception('Failed to load balance: ${e.response?.statusCode} $msg');
    }
  }
}
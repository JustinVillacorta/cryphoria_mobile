import 'package:dio/dio.dart';

class WalletRemoteDataSource {
  final String baseUrl;
  final Dio dio;

  WalletRemoteDataSource({
    this.baseUrl = "http://localhost:8000/api/wallets/",
    Dio? dio,
  }) : dio = dio ?? Dio();

  /// Connect wallet using private key - sends private key to backend for encryption
  Future<Map<String, dynamic>> connectWallet({
    required String privateKey,
    required String walletName,
    required String walletType,
  }) async {
    final url = '${baseUrl}connect_wallet/';
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

  /// Get wallet balance which includes wallet information
  Future<Map<String, dynamic>> getWalletBalance() async {
    final url = '${baseUrl}get_wallet_balance/';
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            // Authentication handled by Dio interceptor
          },
        ),
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to get wallet balance: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to get wallet balance: $status $body');
    }
  }

  /// Send ETH transaction using connected wallet (no private key required)
  Future<Map<String, dynamic>> sendEth({
    required String toAddress,
    required double amount,
    String? gasPrice,
    String? gasLimit,
    String? company,
    String? category,
    String? description,
    bool? isInvesting,
    String? investorName,
  }) async {
    final url = '/api/eth/send/';
    try {
      final requestData = {
        'to_address': toAddress, // Backend expects 'to_address', not 'to'
        'amount': amount.toString(),
        'gas_price': gasPrice ?? "20",
        'gas_limit': gasLimit ?? "21000",
        'company': company ?? "",
        'category': category ?? "",
        'description': description ?? "",
        'is_investing': isInvesting ?? false,
        'investor_name': investorName ?? "",
      };
      
      // Validate address format
      if (!toAddress.startsWith('0x') || toAddress.length != 42) {
        throw Exception('Invalid address format: $toAddress');
      }
      
      // Check if this is a known problematic address
      if (toAddress.toLowerCase() == '0x180aea398ca37802102bc88b5f9a706faf487d03') {
        print('⚠️ WARNING: This address has been problematic in tests. Consider using a different address.');
      }
      
      print('🌐 WalletRemoteDataSource.sendEth called');
      print('📋 Request data: $requestData');
      print('📋 URL: $url');
      print('📋 toAddress parameter: $toAddress');
      print('📋 toAddress in requestData: ${requestData['to_address']}');
      print('📋 Are they equal? ${toAddress == requestData['to_address']}');
      
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: requestData,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to send ETH: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to send ETH: $status $body');
    }
  }

  /// Disconnect wallet and remove from backend
  Future<void> disconnectWallet(String walletAddress) async {
    final url = '${baseUrl}disconnect_wallet/';
    try {
      final response = await dio.delete(
        url,
        queryParameters: {
          'wallet_address': walletAddress,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      
      // Accept both success: true and 200 status as successful disconnect
      if (response.statusCode == 200) {
        // Check if response has success field, if not, assume success for 200 status
        if (response.data is Map && response.data.containsKey('success')) {
          if (response.data['success'] != true) {
            throw Exception('Failed to disconnect wallet: ${response.data['error'] ?? 'Unknown error'}');
          }
        }
        // If no success field but 200 status, assume success
      } else {
        throw Exception('Failed to disconnect wallet: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to disconnect wallet: $status $body');
    }
  }

  /// Convert cryptocurrency to fiat currency
  Future<Map<String, dynamic>> convertCryptoToFiat({
    required String value,
    required String from,
    required String to,
  }) async {
    final url = 'http://localhost:8000/api/conversion/crypto-to-fiat/';
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            // Authentication handled by Dio interceptor
          },
        ),
        data: {
          'value': value,
          'from': from,
          'to': to,
        },
      );
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to convert crypto to fiat: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to convert crypto to fiat: $status $body');
    }
  }
}
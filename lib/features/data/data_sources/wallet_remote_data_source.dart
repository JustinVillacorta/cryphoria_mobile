import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WalletRemoteDataSource {
  final String baseUrl;
  final Dio dio;

  WalletRemoteDataSource({
    this.baseUrl = "http://localhost:8000/api/wallets/",
    Dio? dio,
  }) : dio = dio ?? Dio();

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

  Future<Map<String, dynamic>> getWalletBalance() async {
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
        'to_address': toAddress,
        'amount': amount.toString(),
        'gas_price': gasPrice ?? "20",
        'gas_limit': gasLimit ?? "21000",
        'company': company ?? "",
        'category': category ?? "",
        'description': description ?? "",
        'is_investing': isInvesting ?? false,
        'investor_name': investorName ?? "",
      };

      if (!toAddress.startsWith('0x') || toAddress.length != 42) {
        throw Exception('Invalid address format: $toAddress');
      }

      if (toAddress.toLowerCase() == '0x180aea398ca37802102bc88b5f9a706faf487d03') {
        debugPrint('⚠️ WARNING: This address has been problematic in tests. Consider using a different address.');
      }

      debugPrint('🌐 WalletRemoteDataSource.sendEth called');
      debugPrint('📋 Request data: $requestData');
      debugPrint('📋 URL: $url');
      debugPrint('📋 toAddress parameter: $toAddress');
      debugPrint('📋 toAddress in requestData: ${requestData['to_address']}');
      debugPrint('📋 Are they equal? ${toAddress == requestData['to_address']}');

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

      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('success')) {
          if (response.data['success'] != true) {
            throw Exception('Failed to disconnect wallet: ${response.data['error'] ?? 'Unknown error'}');
          }
        }
      } else {
        throw Exception('Failed to disconnect wallet: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to disconnect wallet: $status $body');
    }
  }

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



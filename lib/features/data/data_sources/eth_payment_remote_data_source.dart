import 'package:dio/dio.dart';
import '../../domain/entities/eth_transaction.dart';
import '../models/eth_transaction_model.dart';

abstract class EthPaymentRemoteDataSource {
  Future<EthTransactionResult> sendEthTransaction(EthTransactionRequest request);
  Future<GasEstimate> estimateGas(GasEstimateRequest request);
  Future<List<EthTransaction>> getTransactionHistory({
    String? walletId,
    int limit = 50,
    int offset = 0,
    String? status,
  });
  Future<EthTransactionStatus> getTransactionStatus(String transactionHash);
  Future<bool> checkServerHealth();
}

class EthPaymentRemoteDataSourceImpl implements EthPaymentRemoteDataSource {
  final Dio dio;

  EthPaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<EthTransactionResult> sendEthTransaction(EthTransactionRequest request) async {
    print("🌐 EthPaymentRemoteDataSource.sendEthTransaction called");
    print("📋 Transaction request: ${request.toJson()}");
    print("🔗 Base URL: ${dio.options.baseUrl}");
    
    try {
      print("📤 Making POST request to /api/eth/send/");
      print("⏱️ Timeout settings - Connect: ${dio.options.connectTimeout?.inMilliseconds}ms, Receive: ${dio.options.receiveTimeout?.inMilliseconds}ms");
      
      final response = await dio.post(
        '/api/eth/send/',
        data: request.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      print("📥 Send ETH response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return EthTransactionResult.fromJson(data);
      } else {
        throw Exception('Failed to send ETH transaction: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      print("🚨 DioException in send transaction:");
      print("   Type: ${e.type}");
      print("   Message: ${e.message}");
      print("   Response: ${e.response?.data}");
      print("   Status Code: ${e.response?.statusCode}");
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Network timeout: Server is not responding. Please check if the backend server is running.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error: Cannot reach server at ${dio.options.baseUrl}. Please verify the server is running.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print("🚨 Error sending ETH transaction: $e");
      rethrow;
    }
  }

  @override
  Future<GasEstimate> estimateGas(GasEstimateRequest request) async {
    print("🌐 EthPaymentRemoteDataSource.estimateGas called");
    print("📋 Gas estimate request: ${request.toJson()}");
    print("🔗 Base URL: ${dio.options.baseUrl}");
    
    try {
      print("📤 Making POST request to /api/eth/estimate-gas/");
      print("⏱️ Timeout settings - Connect: ${dio.options.connectTimeout?.inMilliseconds}ms, Receive: ${dio.options.receiveTimeout?.inMilliseconds}ms");
      
      final response = await dio.post(
        '/api/eth/estimate-gas/',
        data: request.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print("📥 Gas estimate response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return GasEstimate.fromJson(data);
      } else {
        throw Exception('Failed to estimate gas: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      print("🚨 DioException in gas estimation:");
      print("   Type: ${e.type}");
      print("   Message: ${e.message}");
      print("   Response: ${e.response?.data}");
      print("   Status Code: ${e.response?.statusCode}");
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Network timeout: Server is not responding. Please check if the backend server is running.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error: Cannot reach server at ${dio.options.baseUrl}. Please verify the server is running.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print("🚨 Error estimating gas: $e");
      rethrow;
    }
  }

  @override
  Future<List<EthTransaction>> getTransactionHistory({
    String? walletId,
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    print("🌐 EthPaymentRemoteDataSource.getTransactionHistory called");
    
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (walletId != null) queryParams['wallet_id'] = walletId;
      if (status != null) queryParams['status'] = status;
      
      print("📤 Making GET request to /api/eth/history/ with params: $queryParams");
      
      final response = await dio.get(
        '/api/eth/history/',
        queryParameters: queryParams,
      );

      print("📥 Transaction history response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final transactions = data['transactions'] as List;
        return transactions
            .map((json) => EthTransactionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get transaction history: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print("🚨 Error getting transaction history: $e");
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<EthTransactionStatus> getTransactionStatus(String transactionHash) async {
    print("🌐 EthPaymentRemoteDataSource.getTransactionStatus called");
    print("📋 Transaction hash: $transactionHash");
    
    try {
      print("📤 Making POST request to /api/eth/status/");
      
      final response = await dio.post(
        '/api/eth/status/',
        data: {'transaction_hash': transactionHash},
      );

      print("📥 Transaction status response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return EthTransactionStatus.fromJson(data);
      } else {
        throw Exception('Failed to get transaction status: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print("🚨 Error getting transaction status: $e");
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkServerHealth() async {
    print("🏥 Checking server health...");
    print("🔗 Base URL: ${dio.options.baseUrl}");
    
    try {
      final response = await dio.get(
        '/api/auth/health/',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      print("📥 Health check response:");
      print("📊 Status code: ${response.statusCode}");
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("🚨 Server health check failed:");
      print("   Type: ${e.type}");
      print("   Message: ${e.message}");
      
      if (e.type == DioExceptionType.connectionError) {
        print("💡 Suggestion: Check if backend server is running on ${dio.options.baseUrl}");
      } else if (e.type == DioExceptionType.connectionTimeout) {
        print("💡 Suggestion: Server might be starting up or overloaded");
      }
      
      return false;
    } catch (e) {
      print("🚨 Unexpected error in health check: $e");
      return false;
    }
  }
}
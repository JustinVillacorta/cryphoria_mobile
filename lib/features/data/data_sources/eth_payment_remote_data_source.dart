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

    try {

      final response = await dio.post(
        '/api/eth/send/',
        data: request.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );


      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return EthTransactionResult.fromJson(data);
      } else {
        throw Exception('Failed to send ETH transaction: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {

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
      rethrow;
    }
  }

  @override
  Future<GasEstimate> estimateGas(GasEstimateRequest request) async {

    try {

      final response = await dio.post(
        '/api/eth/estimate-gas/',
        data: request.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );


      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return GasEstimate.fromJson(data);
      } else {
        throw Exception('Failed to estimate gas: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {

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

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (walletId != null) queryParams['wallet_id'] = walletId;
      if (status != null) queryParams['status'] = status;


      final response = await dio.get(
        '/api/eth/history/',
        queryParameters: queryParams,
      );


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
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<EthTransactionStatus> getTransactionStatus(String transactionHash) async {

    try {

      final response = await dio.post(
        '/api/eth/status/',
        data: {'transaction_hash': transactionHash},
      );


      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return EthTransactionStatus.fromJson(data);
      } else {
        throw Exception('Failed to get transaction status: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkServerHealth() async {

    try {
      final response = await dio.get(
        '/api/auth/health/',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );


      return response.statusCode == 200;
    } on DioException catch (e) {

      if (e.type == DioExceptionType.connectionError) {
      } else if (e.type == DioExceptionType.connectionTimeout) {
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
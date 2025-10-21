// lib/features/data/data_sources/smart_invest_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../domain/entities/smart_invest.dart';
import '../../domain/entities/investment_report.dart';

abstract class SmartInvestRemoteDataSource {
  Future<SmartInvestResponse> sendInvestment(SmartInvestRequest request);
  Future<AddressBookUpsertResponse> upsertAddressBookEntry(AddressBookUpsertRequest request);
  Future<AddressBookListResponse> getAddressBookList();
  Future<AddressBookDeleteResponse> deleteAddressBookEntry(String address);
  Future<InvestmentStatistics> getInvestmentStatistics();
}

class SmartInvestRemoteDataSourceImpl implements SmartInvestRemoteDataSource {
  final Dio dio;

  SmartInvestRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<SmartInvestResponse> sendInvestment(SmartInvestRequest request) async {
    // This method is no longer used - we use WalletService.sendEth directly
    // This is kept for interface compatibility but should not be called
    throw UnimplementedError('Use WalletService.sendEth for smart investments');
  }

  @override
  Future<AddressBookUpsertResponse> upsertAddressBookEntry(AddressBookUpsertRequest request) async {
    try {
      final response = await dio.post(
        '/api/address-book/upsert/',
        data: request.toJson(),
      );
      
      if (response.data['success'] == true) {
        return AddressBookUpsertResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to upsert address book entry: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to upsert address book entry: $status $body');
    }
  }

  @override
  Future<AddressBookListResponse> getAddressBookList() async {
    try {
      final response = await dio.get(
        '/api/address-book/list/',
      );
      
      if (response.data['success'] == true) {
        return AddressBookListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get address book list: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to get address book list: $status $body');
    }
  }

  @override
  Future<AddressBookDeleteResponse> deleteAddressBookEntry(String address) async {
    try {
      final response = await dio.delete(
        '/api/address-book/delete/',
        data: {'address': address},
      );
      
      if (response.data['success'] == true) {
        return AddressBookDeleteResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to delete address book entry: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to delete address book entry: $status $body');
    }
  }

  @override
  Future<InvestmentStatistics> getInvestmentStatistics() async {
    try {
      final response = await dio.get(
        '/api/financial/investment-report/statistics/',
      );
      
      if (response.data['success'] == true) {
        return InvestmentStatistics.fromJson(response.data);
      } else {
        throw Exception('Failed to get investment statistics: ${response.data['error'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final status = e.response?.statusCode;
      throw Exception('Failed to get investment statistics: $status $body');
    }
  }
}

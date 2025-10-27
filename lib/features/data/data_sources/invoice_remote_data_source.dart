import 'package:dio/dio.dart';
import '../../domain/entities/invoice.dart';

class InvoiceRemoteDataSource {
  final Dio dio;
  InvoiceRemoteDataSource({required this.dio});

  Future<List<Invoice>> getUserInvoices(String userId) async {
    try {
      final response = await dio.get('/api/invoices/list/');

      final data = response.data;

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic> && data['invoices'] != null) {
          final invoicesList = data['invoices'] as List;
          return invoicesList
              .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Invoice> getInvoiceDetails(String invoiceId) async {
    try {
      final response = await dio.get(
        '/api/invoices/list/',
        queryParameters: {'invoice_id': invoiceId},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          if (data['invoice'] != null) {
            return Invoice.fromJson(data['invoice'] as Map<String, dynamic>);
          } else if (data['invoices'] != null && (data['invoices'] as List).isNotEmpty) {
            return Invoice.fromJson((data['invoices'] as List).first as Map<String, dynamic>);
          } else {
            return Invoice.fromJson(data);
          }
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load invoice details');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    }
  }
}
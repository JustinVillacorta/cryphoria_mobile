import '../../domain/entities/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoicesByUser(String userId);
  Future<Invoice> getInvoiceById(String invoiceId);
}
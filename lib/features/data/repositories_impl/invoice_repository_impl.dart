import '../../domain/entities/invoice.dart';
import '../data_sources/invoice_remote_data_source.dart';
import '../../domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Invoice>> getInvoicesByUser(String userId) async {
    final models = await remoteDataSource.getUserInvoices(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Invoice> getInvoiceById(String invoiceId) async {
    final model = await remoteDataSource.getInvoiceDetails(invoiceId);
    return model.toEntity();
  }
}
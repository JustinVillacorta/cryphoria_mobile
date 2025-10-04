// domain/usecases/get_invoice_by_id_usecase.dart
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/domain/repositories/invoice_repository.dart';


class GetInvoiceById {
  final InvoiceRepository repository;

  GetInvoiceById(this.repository);

  Future<Invoice> call(String invoiceId) async {
    return await repository.getInvoiceById(invoiceId);
  }
}

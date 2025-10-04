// domain/usecases/get_invoices_by_user_usecase.dart
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/domain/repositories/invoice_repository.dart';

class GetInvoicesByUser {
  final InvoiceRepository repository;

  GetInvoicesByUser(this.repository);

  Future<List<Invoice>> call(String userId) {
    return repository.getInvoicesByUser(userId);
  }
}

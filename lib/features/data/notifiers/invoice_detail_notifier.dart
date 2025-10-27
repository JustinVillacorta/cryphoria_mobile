import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Invoice/get_invoice_by_id_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceDetailState {
  final bool isLoading;
  final Invoice? invoice;
  final String? error;

  InvoiceDetailState({this.isLoading = false, this.invoice, this.error});

  InvoiceDetailState copyWith({
    bool? isLoading,
    Invoice? invoice,
    String? error,
  }) {
    return InvoiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      invoice: invoice ?? this.invoice,
      error: error,
    );
  }
}

class InvoiceDetailNotifier extends StateNotifier<InvoiceDetailState> {
  final GetInvoiceById getInvoiceById;

  InvoiceDetailNotifier(this.getInvoiceById) : super(InvoiceDetailState());

  Future<void> fetchInvoice(String invoiceId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoice = await getInvoiceById(invoiceId);
      state = state.copyWith(isLoading: false, invoice: invoice);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
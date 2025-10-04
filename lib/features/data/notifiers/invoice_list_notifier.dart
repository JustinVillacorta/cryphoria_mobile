import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Invoice/get_invoices_by_user_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceListState {
  final bool isLoading;
  final List<Invoice> invoices;
  final String? error;

  InvoiceListState({
    this.isLoading = false,
    this.invoices = const [],
    this.error,
  });

  InvoiceListState copyWith({
    bool? isLoading,
    List<Invoice>? invoices,
    String? error,
  }) {
    return InvoiceListState(
      isLoading: isLoading ?? this.isLoading,
      invoices: invoices ?? this.invoices,
      error: error,
    );
  }
}

class InvoiceListNotifier extends StateNotifier<InvoiceListState> {
  final GetInvoicesByUser getInvoicesByUser;

  InvoiceListNotifier(this.getInvoicesByUser) : super(InvoiceListState());

  Future<void> fetchInvoices(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoices = await getInvoicesByUser(userId);
      state = state.copyWith(isLoading: false, invoices: invoices);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

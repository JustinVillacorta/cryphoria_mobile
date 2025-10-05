// lib/features/presentation/screens/invoice_detail_screen.dart
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/download_pdf_button.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice_header.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice_items.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice_parties.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice_payment_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceByIdProvider(invoiceId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: invoiceAsync.when(
        data: (invoice) => _buildDetailContent(context, invoice),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8B5CF6),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading invoice',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Invoice invoice) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Header
                InvoiceHeaderWidget(invoice: invoice),
                const SizedBox(height: 16),

                // From/To Section
                InvoicePartiesWidget(invoice: invoice),
                const SizedBox(height: 16),

                // Invoice Items
                InvoiceItemsWidget(invoice: invoice),
                const SizedBox(height: 16),

                // Payment Information (only shown if paid)
                PaymentInfoWidget(invoice: invoice),
                if (invoice.status.toLowerCase() == 'paid')
                  const SizedBox(height: 16),

                // Download PDF Button
                DownloadPdfButton(
                  onPressed: () {
                    _handleDownloadPdf(context, invoice);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDownloadPdf(BuildContext context, Invoice invoice) {
    // TODO: Implement PDF generation and download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('PDF generation will be implemented'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invoice/invoice_detail_screen_view/invoice_detail_screen.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/swipable_invoice_card.card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  String? userId;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final authLocalDataSource = ref.read(authLocalDataSourceProvider);
      final id = await authLocalDataSource.getToken();
      setState(() {
        userId = id;
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view invoices')),
      );
    }

    // Fetch invoices for the current user
    final invoicesAsync = ref.watch(invoicesByUserProvider(userId!));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Invoices',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invoices are automatically generated from transactions like payroll, payments sent through "Send Payment", and client payments received.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search invoices...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filter Tabs
              Row(
                children: [
                  _buildFilterTab('All'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Paid'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Pending'),
                ],
              ),
              const SizedBox(height: 20),

              // Invoice List
              Expanded(
                child: invoicesAsync.when(
                  data: (invoices) {
                    // Filter invoices based on search and status
                    List<Invoice> filtered = _filterInvoices(invoices);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No invoices found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        return _buildInvoiceCard(invoice);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading invoices',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$err',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    List<Invoice> filtered = invoices;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((invoice) =>
      invoice.clientName
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          invoice.invoiceNumber
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter (match "Paid" with "PAID", "Pending" with "SENT" or "DRAFT")
    if (selectedFilter != 'All') {
      if (selectedFilter == 'Paid') {
        filtered = filtered
            .where((invoice) => invoice.status.toUpperCase() == 'PAID')
            .toList();
      } else if (selectedFilter == 'Pending') {
        filtered = filtered
            .where((invoice) =>
        invoice.status.toUpperCase() == 'SENT' ||
            invoice.status.toUpperCase() == 'DRAFT')
            .toList();
      }
    }

    return filtered;
  }

  Widget _buildFilterTab(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    // Map backend status to display status
    String displayStatus =
    invoice.status.toUpperCase() == 'PAID' ? 'Paid' : 'Pending';

    // Get first item description or default text
    String description = invoice.items.isNotEmpty
        ? invoice.items.first.description
        : 'Invoice items';

    return SwipeableInvoiceCard(
      invoice: invoice,
      description: description,
      displayStatus: displayStatus,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvoiceDetailScreen(invoiceId: invoice.invoiceId),
          ),
        );
      },
      onDelete: () => _handleDeleteInvoice(invoice),
    );
  }

  Future<void> _handleDeleteInvoice(Invoice invoice) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      invoiceNumber: invoice.invoiceNumber,
    );

    if (confirmed == true) {
      try {
        // TODO: Implement delete invoice use case
        // await ref.read(deleteInvoiceProvider(invoice.invoiceId).future);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Invoice deleted successfully'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Refresh the invoice list
        // ref.invalidate(invoicesByUserProvider(userId!));
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to delete invoice: $e'),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
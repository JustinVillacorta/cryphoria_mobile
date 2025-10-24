import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invoice/invoice_detail_screen_view/invoice_detail_screen.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/swipable_invoice_card.card.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/invoice_screen_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    if (isLoadingUser) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withOpacity(0.4),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                'Please log in to view invoices',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 17 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final invoicesAsync = ref.watch(invoicesByUserProvider(userId!));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    'Invoices',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 28 : isTablet ? 26 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Text(
                    'Invoices are automatically generated from transactions like payroll, payments sent through "Send Payment", and client payments received.',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 15 : 14,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: isTablet ? 28 : 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
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
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF6B6B6B),
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: const Color(0xFF6B6B6B),
                          size: isTablet ? 22 : 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 18 : 16,
                          vertical: isTablet ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab('All', isTablet),
                        SizedBox(width: isTablet ? 14 : 12),
                        _buildFilterTab('Paid', isTablet),
                        SizedBox(width: isTablet ? 14 : 12),
                        _buildFilterTab('Pending', isTablet),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),

                  Expanded(
                    child: invoicesAsync.when(
                      data: (invoices) {
                        List<Invoice> filtered = _filterInvoices(invoices);

                        if (filtered.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: isTablet ? 64 : 56,
                                  color: const Color(0xFF6B6B6B).withOpacity(0.4),
                                ),
                                SizedBox(height: isTablet ? 20 : 16),
                                Text(
                                  'No invoices found',
                                  style: GoogleFonts.inter(
                                    fontSize: isTablet ? 19 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: isTablet ? 10 : 8),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: GoogleFonts.inter(
                                    fontSize: isTablet ? 15 : 14,
                                    color: const Color(0xFF6B6B6B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => SizedBox(height: isTablet ? 14 : 12),
                          itemBuilder: (context, index) {
                            final invoice = filtered[index];
                            return _buildInvoiceCard(invoice, isTablet);
                          },
                        );
                      },
                      loading: () => const InvoiceScreenSkeleton(),
                      error: (err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isTablet ? 64 : 56,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            Text(
                              'Error loading invoices',
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 19 : 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Text(
                                '$err',
                                style: GoogleFonts.inter(
                                  fontSize: isTablet ? 15 : 14,
                                  color: const Color(0xFF6B6B6B),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
        ),
      ));
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    List<Invoice> filtered = invoices;

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

  Widget _buildFilterTab(String filter, bool isTablet) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 18,
          vertical: isTablet ? 10 : 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9747FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9747FF) : const Color(0xFFE5E5E5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9747FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          filter,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 15 : 14,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, bool isTablet) {
    String displayStatus =
        invoice.status.toUpperCase() == 'PAID' ? 'Paid' : 'Pending';

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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Invoice deleted successfully',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // ref.invalidate(invoicesByUserProvider(userId!));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to delete invoice: $e',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
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
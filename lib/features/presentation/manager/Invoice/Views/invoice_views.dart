import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invoice/Views/invoice_detail_screen.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/swipable_invoice_card.card.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/invoice_screen_skeleton.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_search_bar.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_filter_tabs.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_empty_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_error_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_loading_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_login_required_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/invoice/invoice_header.dart';
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
      final authUser = await authLocalDataSource.getAuthUser();
      setState(() {
        userId = authUser?.userId;
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
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: InvoiceLoadingState(),
      );
    }

    if (userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: InvoiceLoginRequiredState(isTablet: isTablet),
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
                  InvoiceHeader(
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                  SizedBox(height: isTablet ? 28 : 24),
                  InvoiceSearchBar(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                  InvoiceFilterTabs(
                    selectedFilter: selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                  Expanded(
                    child: invoicesAsync.when(
                      data: (invoices) {
                        List<Invoice> filtered = _filterInvoices(invoices);

                        if (filtered.isEmpty) {
                          return InvoiceEmptyState(isTablet: isTablet);
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
                      error: (err, stack) => InvoiceErrorState(
                        error: err,
                        isTablet: isTablet,
                        horizontalPadding: horizontalPadding,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
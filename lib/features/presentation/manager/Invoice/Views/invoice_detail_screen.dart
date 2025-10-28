import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/reports/pdf_generation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceByIdProvider(invoiceId));
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1A1A1A),
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Invoice Details',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf_outlined,
              color: const Color(0xFF1A1A1A),
              size: isTablet ? 24 : 22,
            ),
            onPressed: () {
              invoiceAsync.whenData((invoice) => _handleDownloadPdf(context, invoice));
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: invoiceAsync.when(
            data: (invoice) => _buildDetailContent(context, invoice, isTablet, isDesktop),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
                strokeWidth: 2.5,
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : isTablet ? 24.0 : 20.0),
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
                      'Error loading invoice',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 19 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Text(
                      err.toString(),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF6B6B6B),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Invoice invoice, bool isTablet, bool isDesktop) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildInvoiceHeaderCard(invoice, isSmallScreen, isTablet, isDesktop),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildPartiesCard(invoice, isSmallScreen, isTablet, isDesktop),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildItemsCard(invoice, isSmallScreen, isTablet, isDesktop),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (invoice.status.toLowerCase() == 'paid') ...[
            _buildPaymentInfoCard(invoice, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isSmallScreen ? 16 : 20),
          ],
          SizedBox(height: isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeaderCard(Invoice invoice, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 22 : isTablet ? 21 : 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      'Issued: ${_formatDate(invoice.issueDate)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              _buildStatusBadge(invoice.status, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesCard(Invoice invoice, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parties',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6B6B),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Cryphoria Mobile',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6B6B),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      invoice.clientName,
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Invoice invoice, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
            child: Text(
              'Invoice Items',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 17 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoice.items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: const Color(0xFFE5E5E5),
            ),
            itemBuilder: (context, index) {
              final item = invoice.items[index];
              return _buildItemCard(item, isSmallScreen, isTablet, isDesktop);
            },
          ),
          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E5E5), width: 1.5),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal:', invoice.subtotal, false, isTablet),
                SizedBox(height: isSmallScreen ? 10 : 12),
                _buildTotalRow('Tax:', invoice.taxAmount, false, isTablet),
                SizedBox(height: isSmallScreen ? 14 : 16),
                Divider(color: const Color(0xFFE5E5E5), thickness: 1.5),
                SizedBox(height: isSmallScreen ? 14 : 16),
                _buildTotalRow('Total:', invoice.totalAmount, true, isTablet),
                SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    invoice.currency,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 12 : 11,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.description,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.quantity.toString(),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit Price',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '\$${item.unitPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(Invoice invoice, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Date',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      _formatDate(invoice.issueDate),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'N/A',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isBold, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isBold ? (isTablet ? 17 : 16) : (isTablet ? 15 : 14),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: isBold ? const Color(0xFF1A1A1A) : const Color(0xFF6B6B6B),
            height: 1.3,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: isBold ? (isTablet ? 19 : 18) : (isTablet ? 15 : 14),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isTablet) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outlined;
        break;
      case 'pending':
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.schedule_outlined;
        break;
      case 'overdue':
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
        textColor = const Color(0xFFEF4444);
        icon = Icons.error_outline;
        break;
      default:
        bgColor = const Color(0xFF6B6B6B).withValues(alpha: 0.1);
        textColor = const Color(0xFF6B6B6B);
        icon = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 12,
        vertical: isTablet ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 17 : 16, color: textColor),
          SizedBox(width: isTablet ? 7 : 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  void _handleDownloadPdf(BuildContext context, Invoice invoice) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );

      final pdfPath = await PdfGenerationHelper.generateInvoicePdf(invoice);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (pdfPath.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invoice PDF saved successfully!\nTap to open: ${pdfPath.split('/').last}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                final scaffoldContext = context;
                try {
                  await OpenFile.open(pdfPath);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Could not open file: $e',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.orange[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate invoice PDF',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error generating PDF: $e',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
// lib/features/presentation/manager/Payslip/Views/payslip_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../../../../domain/entities/payslip.dart';
import 'package:intl/intl.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';

class PayslipDetailsView extends ConsumerWidget {
  final Payslip payslip;

  const PayslipDetailsView({Key? key, required this.payslip}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
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
          'Payslip Details',
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
            onPressed: () => _generatePdf(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildHeaderCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildPayslipInfoCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildEarningsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildDeductionsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildNetPayCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildPaymentStatusCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 24 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9747FF), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 70 : isTablet ? 65 : 60,
            height: isDesktop ? 70 : isTablet ? 65 : 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (payslip.employeeName ?? 'U').substring(0, 1).toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : isTablet ? 26 : 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 18 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payslip.employeeName ?? 'Unknown Employee',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  payslip.position ?? 'No position specified',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  payslip.department ?? 'No department specified',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipInfoCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payslip Number',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  payslip.payslipNumber ?? 'Unknown Number',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Pay Period',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildAmountRow('Base Salary', payslip.baseSalary, false, isTablet),
          SizedBox(height: isSmallScreen ? 10 : 12),
          Divider(color: const Color(0xFFE5E5E5), thickness: 1.5),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildAmountRow('Total Earnings', payslip.totalEarnings, true, isTablet),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final hasDeductions = payslip.totalDeductions > 0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deductions',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (hasDeductions) ...[
            if (payslip.taxDeduction > 0) ...[
              _buildAmountRow('Tax Deduction', payslip.taxDeduction, false, isTablet),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.insuranceDeduction > 0) ...[
              _buildAmountRow('Insurance', payslip.insuranceDeduction, false, isTablet),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.retirementDeduction > 0) ...[
              _buildAmountRow('Retirement', payslip.retirementDeduction, false, isTablet),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            if (payslip.otherDeductions > 0) ...[
              _buildAmountRow('Other Deductions', payslip.otherDeductions, false, isTablet),
              SizedBox(height: isSmallScreen ? 10 : 12),
            ],
            Divider(color: const Color(0xFFE5E5E5), thickness: 1.5),
            SizedBox(height: isSmallScreen ? 10 : 12),
            _buildAmountRow('Total Deductions', payslip.totalDeductions, true, isTablet),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                child: Text(
                  'No deductions',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    color: const Color(0xFF6B6B6B),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetPayCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'NET PAY',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 10),
          Text(
            '\$${payslip.finalNetPay.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 42 : isTablet ? 38 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (payslip.cryptoAmount > 0) ...[
            SizedBox(height: isTablet ? 10 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14 : 12,
                vertical: isTablet ? 8 : 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${payslip.cryptoAmount.toStringAsFixed(6)} ${payslip.cryptocurrency ?? 'ETH'}',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Status',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            decoration: BoxDecoration(
              color: _getStatusColor(payslip.statusEnum).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(payslip.statusEnum).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(payslip.statusEnum),
                      color: _getStatusColor(payslip.statusEnum),
                      size: isTablet ? 22 : 20,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Text(
                      payslip.statusEnum.displayName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(payslip.statusEnum),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 14),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: isTablet ? 18 : 16,
                      color: const Color(0xFF6B6B6B),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      'Pay Date: ${DateFormat('MMMM dd, yyyy').format(payslip.payDate)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, bool isTotal, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFF9747FF).withOpacity(0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: isTotal ? Border.all(color: const Color(0xFF9747FF).withOpacity(0.3), width: 1.5) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 16 : 15) : (isTablet ? 15 : 14),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 18 : 17) : (isTablet ? 16 : 15),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF9747FF) : const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return Icons.edit_outlined;
      case PayslipStatus.generated:
        return Icons.check_circle_outlined;
      case PayslipStatus.sent:
        return Icons.send_outlined;
      case PayslipStatus.paid:
        return Icons.check_circle_outlined;
      case PayslipStatus.cancelled:
        return Icons.cancel_outlined;
      case PayslipStatus.processing:
        return Icons.hourglass_empty_outlined;
      case PayslipStatus.failed:
        return Icons.error_outline;
      case PayslipStatus.pending:
        return Icons.schedule_outlined;
    }
  }

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return const Color(0xFFF59E0B);
      case PayslipStatus.generated:
        return const Color(0xFF10B981);
      case PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case PayslipStatus.paid:
        return const Color(0xFF10B981);
      case PayslipStatus.cancelled:
        return const Color(0xFFEF4444);
      case PayslipStatus.processing:
        return const Color(0xFFF59E0B);
      case PayslipStatus.failed:
        return const Color(0xFFEF4444);
      case PayslipStatus.pending:
        return const Color(0xFF6B6B6B);
    }
  }

  void _generatePdf(BuildContext context) async {
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

      final payslipData = payslip.toJson();
      final pdfPath = await PdfGenerationHelper.generatePayslipPdf(payslipData);
      
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (pdfPath.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payslip PDF saved successfully!\nTap to open: ${pdfPath.split('/').last}',
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
                try {
                  await OpenFile.open(pdfPath);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
              },
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate payslip PDF',
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
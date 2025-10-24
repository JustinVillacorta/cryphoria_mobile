import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../../domain/entities/payslip.dart';
import '../providers/payroll_history_providers.dart';
import '../../../../presentation/widgets/reports/pdf_generation_helper.dart';

class PayslipDetailsView extends ConsumerWidget {
  final String payslipId;

  const PayslipDetailsView({
    Key? key,
    required this.payslipId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    return payrollDetailsAsync.when(
      data: (data) {
        final payslip = data.payslips.firstWhere(
          (p) => p.payslipId == payslipId,
          orElse: () => throw Exception('Payslip not found'),
        );
        
        return _buildPayslipDetails(context, payslip, isTablet, isDesktop);
      },
      loading: () => Scaffold(
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
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
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
        ),
        body: Center(
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
                'Failed to load payslip details',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayslipDetails(BuildContext context, Payslip payslip, bool isTablet, bool isDesktop) {
    final size = MediaQuery.of(context).size;
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
            onPressed: () => _generatePdf(context, payslip),
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
                _buildPayslipHeader(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildStatusCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildPaymentDetailsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildEarningsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildDeductionsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildTaxBreakdownCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildCryptoDetailsCard(payslip, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: isSmallScreen ? 24 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayslipHeader(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payslip.payslipNumber ?? 'Unknown',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 24 : isTablet ? 22 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      payslip.employeeName ?? 'Unknown Employee',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: isTablet ? 26 : 24,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo(
                  'Pay Period',
                  '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                  isTablet,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildHeaderInfo(
                  'Pay Date',
                  DateFormat('MMM dd, yyyy').format(payslip.payDate),
                  isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 13 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.75),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final status = payslip.status ?? 'UNKNOWN';
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
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
          Container(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(status),
              color: statusColor,
              size: isTablet ? 22 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (payslip.paymentProcessed == true)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 10,
                vertical: isTablet ? 7 : 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PAID',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                  height: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Payment Details',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildPaymentRow('Gross Amount', '\$${payslip.grossAmount.toStringAsFixed(2)}', const Color(0xFF3B82F6), false, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildPaymentRow('Total Deductions', '\$${payslip.totalDeductions.toStringAsFixed(2)}', const Color(0xFFEF4444), false, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildPaymentRow('Net Amount', '\$${payslip.netAmount.toStringAsFixed(2)}', const Color(0xFF10B981), false, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildPaymentRow('Final Net Pay', '\$${payslip.finalNetPay.toStringAsFixed(2)}', const Color(0xFF9747FF), true, isTablet),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, Color color, bool isTotal, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? color.withOpacity(0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: isTotal ? Border.all(color: color.withOpacity(0.3), width: 1.5) : null,
      ),
      child: Row(
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
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 18 : 17) : (isTablet ? 16 : 15),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? color : const Color(0xFF1A1A1A),
              height: 1.2,
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
          _buildEarningsRow('Base Salary', payslip.baseSalary, false, isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildEarningsRow('Total Earnings', payslip.totalEarnings, true, isSmallScreen, isTablet),
        ],
      ),
    );
  }

  Widget _buildEarningsRow(String label, double amount, bool isTotal, bool isSmallScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: isTotal ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1.5) : null,
      ),
      child: Row(
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
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 18 : 17) : (isTablet ? 16 : 15),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF10B981) : const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
          _buildDeductionsRow('Tax Deduction', payslip.taxDeduction, false, isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildDeductionsRow('Insurance Deduction', payslip.insuranceDeduction, false, isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildDeductionsRow('Retirement Deduction', payslip.retirementDeduction, false, isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildDeductionsRow('Other Deductions', payslip.otherDeductions, false, isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildDeductionsRow('Total Deductions', payslip.totalDeductions, true, isSmallScreen, isTablet),
        ],
      ),
    );
  }

  Widget _buildDeductionsRow(String label, double amount, bool isTotal, bool isSmallScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFFEF4444).withOpacity(0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: isTotal ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.3), width: 1.5) : null,
      ),
      child: Row(
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
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? (isTablet ? 18 : 17) : (isTablet ? 16 : 15),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFFEF4444) : const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdownCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
    if (payslip.taxBreakdown == null || payslip.taxBreakdown!.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Tax Breakdown',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ...payslip.taxBreakdown!.entries.map((entry) => 
            Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
              child: _buildTaxRow(entry.key, entry.value as double, isTablet),
            )
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, double amount, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label.replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDetailsCard(Payslip payslip, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Cryptocurrency Details',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildCryptoRow('Currency', payslip.cryptocurrency ?? 'ETH', isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildCryptoRow('Crypto Amount', '${payslip.cryptoAmount.toStringAsFixed(6)} ${payslip.cryptocurrency ?? 'ETH'}', isSmallScreen, isTablet),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildCryptoRow('USD Equivalent', '\$${payslip.usdEquivalent.toStringAsFixed(2)}', isSmallScreen, isTablet),
          if (payslip.employeeWallet != null) ...[
            SizedBox(height: isSmallScreen ? 8 : 10),
            _buildCryptoRow('Wallet Address', payslip.employeeWallet!, isSmallScreen, isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildCryptoRow(String label, String value, bool isSmallScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return const Color(0xFF10B981);
      case 'SCHEDULED':
      case 'GENERATED':
        return const Color(0xFF3B82F6);
      case 'FAILED':
        return const Color(0xFFEF4444);
      case 'PROCESSING':
        return const Color(0xFFF59E0B);
      case 'PENDING':
      case 'DRAFT':
        return const Color(0xFF6B6B6B);
      case 'SENT':
        return const Color(0xFF9747FF);
      default:
        return const Color(0xFF6B6B6B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return Icons.check_circle_outlined;
      case 'SCHEDULED':
      case 'GENERATED':
        return Icons.schedule_outlined;
      case 'FAILED':
        return Icons.error_outline;
      case 'PROCESSING':
        return Icons.hourglass_empty_outlined;
      case 'PENDING':
      case 'DRAFT':
        return Icons.schedule_outlined;
      case 'SENT':
        return Icons.send_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _generatePdf(BuildContext context, Payslip payslip) async {
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

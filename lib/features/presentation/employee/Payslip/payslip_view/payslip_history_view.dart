import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'payslip_details_view.dart';
import '../providers/payroll_history_providers.dart';
import '../../../../domain/entities/payslip.dart';

class PayslipScreen extends ConsumerWidget {
  const PayslipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollDetailsAsync = ref.watch(payrollDetailsProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(left: isDesktop ? 32 : isTablet ? 24 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Payroll History',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1A1A),
                  fontSize: isDesktop ? 22 : isTablet ? 21 : 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Text(
                'Track and manage your payment records',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: isTablet ? 90 : 80,
      ),
      body: payrollDetailsAsync.when(
        data: (payrollDetails) => _buildContent(context, payrollDetails, isTablet, isDesktop),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
        error: (error, stackTrace) => Center(
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
                'Failed to load payroll data',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : isTablet ? 24 : 20),
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
              SizedBox(height: isTablet ? 28 : 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(payrollDetailsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 24,
                    vertical: isTablet ? 14 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PayslipsResponse payrollDetails, bool isTablet, bool isDesktop) {
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1200.0 : isTablet ? 900.0 : double.infinity;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 12 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildTotalEntriesCard(payrollDetails.payslips, isSmallScreen, isTablet, isDesktop),
              SizedBox(height: isTablet ? 16 : 12),
              _buildPaymentStatisticsCard(payrollDetails.payslips, isSmallScreen, isTablet, isDesktop),
              SizedBox(height: isTablet ? 16 : 12),
              _buildFinancialSummaryCard(payrollDetails.payslips, isSmallScreen, isTablet, isDesktop),
              SizedBox(height: isTablet ? 24 : 16),
              
              // Payslip Entries
              _buildPayslipEntriesCard(context, payrollDetails.payslips, isSmallScreen, isTablet, isDesktop),
              SizedBox(height: isTablet ? 28 : 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalEntriesCard(List<Payslip> payslips, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ENTRIES',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.75),
                    letterSpacing: 0.5,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  '${payslips.length}',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 32 : isTablet ? 30 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.show_chart_outlined,
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatisticsCard(List<Payslip> payslips, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Payment Statistics',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          _buildStatisticRow('Paid', payslips.where((p) => p.status == 'PAID').length, const Color(0xFF10B981), Icons.check_circle_outlined, isTablet),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildStatisticRow('Sent', payslips.where((p) => p.status == 'SENT').length, const Color(0xFF3B82F6), Icons.send_outlined, isTablet),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildStatisticRow('Generated', payslips.where((p) => p.status == 'GENERATED').length, const Color(0xFFF59E0B), Icons.schedule_outlined, isTablet),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, int count, Color color, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isTablet ? 20 : 18),
          SizedBox(width: isTablet ? 12 : 10),
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
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(List<Payslip> payslips, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Financial Summary',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          _buildFinancialRow(
            'Total Paid',
            '\$${payslips.where((p) => p.status == 'PAID').fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}',
            const Color(0xFF10B981),
            Icons.attach_money_outlined,
            isTablet,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildFinancialRow(
            'Total Pending',
            '\$${payslips.where((p) => p.status != 'PAID').fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}',
            const Color(0xFFF59E0B),
            Icons.schedule_outlined,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 10,
        horizontal: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isTablet ? 20 : 18),
          SizedBox(width: isTablet ? 12 : 10),
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
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipEntriesCard(BuildContext context, List<Payslip> payslips, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Payslip Entries',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            'All your payment transactions',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 14 : 13,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          if (payslips.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 48 : 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: isTablet ? 56 : 48,
                      color: const Color(0xFF6B6B6B).withOpacity(0.4),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'No payslips found',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      'Your payment history will appear here',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 14 : 13,
                        color: const Color(0xFF6B6B6B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...payslips.map((payslip) => _buildPayslipEntryCard(context, payslip, isSmallScreen, isTablet)).toList(),
        ],
      ),
    );
  }

  Widget _buildPayslipEntryCard(BuildContext context, Payslip payslip, bool isSmallScreen, bool isTablet) {
    final String date = DateFormat('MMM dd, yyyy').format(payslip.payDate);
    final String cryptoAmount = '${payslip.cryptoAmount.toStringAsFixed(4)} ${payslip.cryptocurrency ?? 'ETH'}';
    final String fiatAmount = '\$${payslip.finalNetPay.toStringAsFixed(2)} USD';

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PayslipDetailsView(payslipId: payslip.payslipId ?? ''),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 18 : 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 8,
                        vertical: isTablet ? 6 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payslip.status ?? 'PENDING').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(payslip.status ?? 'PENDING'),
                            color: _getStatusColor(payslip.status ?? 'PENDING'),
                            size: isTablet ? 14 : 12,
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            (payslip.status ?? 'PENDING').toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(payslip.status ?? 'PENDING'),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 8),
                    Text(
                      'ID: ${(payslip.payslipId ?? 'unknown').substring(0, 8)}...',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 18 : 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cryptoAmount,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 17 : 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    fiatAmount,
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
}
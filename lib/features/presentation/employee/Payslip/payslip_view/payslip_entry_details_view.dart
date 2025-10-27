import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../../domain/entities/payroll_entry.dart';
import '../providers/payroll_history_providers.dart';
import '../../../../presentation/widgets/reports/pdf_generation_helper.dart';

class PayslipEntryDetailsView extends ConsumerWidget {
  final String entryId;

  const PayslipEntryDetailsView({
    super.key,
    required this.entryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryDetailsAsync = ref.watch(payrollEntryDetailsProvider(entryId));
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;


    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: entryDetailsAsync.when(
        data: (entry) => _buildContent(context, entry, isTablet, isDesktop),
        loading: () => _buildLoadingState(isTablet),
        error: (error, stackTrace) => _buildErrorState(context, ref, error, isTablet, isDesktop),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PayrollEntry entry, bool isTablet, bool isDesktop) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Column(
      children: [
        _buildHeader(context, isTablet, isDesktop),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildEntryInformationSection(entry, isSmallScreen, isTablet, isDesktop),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildTransactionDetailsSection(entry, isSmallScreen, isTablet, isDesktop),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildActionButtons(context, entry, isTablet),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Loading entry details...',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 15,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isTablet, bool isDesktop) {
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              'Failed to load entry details',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            SizedBox(height: isTablet ? 28 : 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(payrollEntryDetailsProvider(entryId));
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
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32 : isTablet ? 24 : 20,
        50,
        isDesktop ? 32 : isTablet ? 24 : 20,
        isTablet ? 24 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9747FF), Color(0xFF7C3AED)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: isTablet ? 26 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 18 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payroll Entry Details',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 22 : isTablet ? 21 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  'Complete transaction information',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: isTablet ? 22 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryInformationSection(PayrollEntry entry, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            children: [
              Text(
                'Entry Information',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 12,
                  vertical: isTablet ? 8 : 7,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.status ?? 'PENDING'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(entry.status ?? 'PENDING'),
                      color: Colors.white,
                      size: isTablet ? 17 : 16,
                    ),
                    SizedBox(width: isTablet ? 7 : 6),
                    Text(
                      (entry.status ?? 'PENDING').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.tag_outlined,
                  label: 'Entry ID',
                  value: entry.entryId ?? 'Unknown',
                  iconColor: const Color(0xFF6B6B6B),
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Payment Date',
                  value: DateFormat('MMMM d, yyyy').format(entry.paymentDate),
                  iconColor: const Color(0xFF6B6B6B),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 14 : 12),

          _buildInfoCard(
            icon: Icons.access_time_outlined,
            label: 'Processed At',
            value: entry.processedAt != null 
                ? DateFormat('MMMM d, yyyy \'at\' hh:mm a').format(entry.processedAt!)
                : 'Not processed yet',
            iconColor: const Color(0xFFF59E0B),
            isFullWidth: true,
            isTablet: isTablet,
          ),

          SizedBox(height: isTablet ? 14 : 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.attach_money_outlined,
                  label: 'Amount',
                  value: '${entry.amount.toStringAsFixed(6)} ${entry.cryptocurrency ?? 'ETH'}',
                  iconColor: const Color(0xFF3B82F6),
                  backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.attach_money_outlined,
                  label: 'USD Equivalent',
                  value: '\$${entry.usdEquivalent.toStringAsFixed(2)}',
                  iconColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 14 : 12),

          _buildInfoCard(
            icon: Icons.credit_card_outlined,
            label: 'Payment Method',
            value: 'MetaMask',
            iconColor: const Color(0xFF6B6B6B),
            isFullWidth: true,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsSection(PayrollEntry entry, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            'Transaction Details',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 19 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),

          _buildInfoCard(
            icon: Icons.tag_outlined,
            label: 'Transaction Hash',
            value: entry.transactionHash ?? 'Not available',
            iconColor: const Color(0xFF6B6B6B),
            isFullWidth: true,
            isTablet: isTablet,
          ),

          SizedBox(height: isTablet ? 14 : 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.local_gas_station_outlined,
                  label: 'Gas Fee',
                  value: entry.gasFee != null 
                      ? '${entry.gasFee!.toStringAsFixed(6)} ${entry.cryptocurrency ?? 'ETH'}' 
                      : 'Not available',
                  iconColor: const Color(0xFF6B6B6B),
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildInfoCard(
                  icon: _getStatusIcon(entry.status ?? 'PENDING'),
                  label: 'Status',
                  value: (entry.status ?? 'PENDING').toUpperCase(),
                  iconColor: _getStatusColor(entry.status ?? 'PENDING'),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? backgroundColor,
    bool isFullWidth = false,
    required bool isTablet,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: isTablet ? 20 : 18,
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B6B),
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PayrollEntry entry, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadPayslipPdf(context, entry),
            icon: Icon(Icons.download_outlined, size: isTablet ? 20 : 18),
            label: Text(
              'Download PDF',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(width: isTablet ? 14 : 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, size: isTablet ? 20 : 18),
            label: Text(
              'Close',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
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

  Future<void> _downloadPayslipPdf(BuildContext context, PayrollEntry entry) async {
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

      final payslipData = {
        'payslip_number': 'PS-${entry.entryId?.substring(0, 8) ?? 'UNKNOWN'}',
        'employee_name': entry.employeeName ?? 'Unknown Employee',
        'employee_id': entry.userId ?? 'Unknown ID',
        'employee_email': 'N/A',
        'department': 'N/A',
        'position': 'N/A',
        'pay_period_start': entry.startDate.toIso8601String(),
        'pay_period_end': entry.paymentDate.toIso8601String(),
        'pay_date': entry.paymentDate.toIso8601String(),
        'base_salary': entry.salaryAmount,
        'salary_currency': entry.salaryCurrency ?? 'USD',
        'overtime_pay': 0.0,
        'bonus': 0.0,
        'allowances': 0.0,
        'total_earnings': entry.salaryAmount,
        'tax_deduction': 0.0,
        'insurance_deduction': 0.0,
        'retirement_deduction': 0.0,
        'other_deductions': 0.0,
        'total_deductions': 0.0,
        'final_net_pay': entry.usdEquivalent,
        'cryptocurrency': entry.cryptocurrency ?? 'ETH',
        'crypto_amount': entry.amount,
        'usd_equivalent': entry.usdEquivalent,
        'transaction_hash': entry.transactionHash,
        'status': entry.status ?? 'UNKNOWN',
        'notes': entry.notes ?? 'Generated from payroll entry',
      };

      final filePath = await PdfGenerationHelper.generatePayslipPdf(payslipData);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF saved successfully!\nTap to open: ${filePath.split('/').last}',
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
                  await OpenFile.open(filePath);
                } catch (e) {
                  if (!context.mounted) return;
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
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate PDF: $e',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
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
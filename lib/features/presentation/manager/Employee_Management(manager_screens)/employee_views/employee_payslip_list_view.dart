import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/payslip.dart' as payslip_entity;
import '../../Payslip/Views/payslip_details_view.dart';

class EmployeePayslipListView extends StatelessWidget {
  final Employee employee;
  final List<payslip_entity.Payslip> payslips;
  final VoidCallback? onRefresh;

  const EmployeePayslipListView({
    super.key,
    required this.employee,
    required this.payslips,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9747FF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${employee.name} - Payslips',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: Icon(
                Icons.refresh_outlined,
                color: Colors.white,
                size: isTablet ? 24 : 22,
              ),
              onPressed: onRefresh,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: RefreshIndicator(
            onRefresh: onRefresh != null ? () async => onRefresh!() : () async {},
            color: const Color(0xFF9747FF),
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallScreen ? 8 : 12),

                  _buildEmployeeInfoCard(employee, isSmallScreen, isTablet, isDesktop),
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  _buildPayslipsList(payslips, isSmallScreen, isTablet, isDesktop, context),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard(Employee employee, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
      child: Row(
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              color: const Color(0xFF9747FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_outline,
              color: const Color(0xFF9747FF),
              size: isTablet ? 30 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  '${employee.position ?? 'Employee'} • ${employee.department ?? 'General'}',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 14 : 13,
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  'ID: ${employee.userId}',
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 6 : 5,
            ),
            decoration: BoxDecoration(
              color: employee.isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              employee.isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: employee.isActive ? const Color(0xFF10B981) : Colors.red,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipsList(List<payslip_entity.Payslip> payslips, bool isSmallScreen, bool isTablet, bool isDesktop, BuildContext context) {
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
            'All Payslips',
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
            '${payslips.length} payslip${payslips.length == 1 ? '' : 's'} found',
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
                      color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
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
                      'This employee has no payslip records',
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
            ...payslips.map((payslip) => _buildPayslipHistoryItem(payslip, isSmallScreen, isTablet, context)),
        ],
      ),
    );
  }

  Widget _buildPayslipHistoryItem(payslip_entity.Payslip payslip, bool isSmallScreen, bool isTablet, BuildContext context) {
    final String payPeriod = '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}';
    final String payDate = DateFormat('MMM dd, yyyy').format(payslip.payDate);
    final String amount = '\$${payslip.finalNetPay.toStringAsFixed(2)}';

    final double cardPadding = isTablet ? 18 : 16;
    final double dateSize = isTablet ? 16 : 15;
    final double detailSize = isTablet ? 14 : 13;
    final double amountSize = isTablet ? 18 : 17;
    final double buttonSize = isTablet ? 13 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payPeriod,
                  style: GoogleFonts.inter(
                    fontSize: dateSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Pay Date: $payDate',
                  style: GoogleFonts.inter(
                    fontSize: detailSize,
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 8,
                    vertical: isTablet ? 5 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    payslip.statusEnum.displayName,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 12 : 11,
                      color: _getStatusColor(payslip.statusEnum),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              TextButton(
                onPressed: () => _viewPayslip(payslip, context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 14,
                    vertical: isTablet ? 8 : 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9747FF),
                    fontSize: buttonSize,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(payslip_entity.PayslipStatus status) {
    switch (status) {
      case payslip_entity.PayslipStatus.paid:
        return const Color(0xFF10B981);
      case payslip_entity.PayslipStatus.generated:
        return const Color(0xFF3B82F6);
      case payslip_entity.PayslipStatus.failed:
        return const Color(0xFFEF4444);
      case payslip_entity.PayslipStatus.processing:
        return const Color(0xFFF59E0B);
      case payslip_entity.PayslipStatus.pending:
      case payslip_entity.PayslipStatus.draft:
        return const Color(0xFF6B6B6B);
      case payslip_entity.PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case payslip_entity.PayslipStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  void _viewPayslip(payslip_entity.Payslip payslip, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayslipDetailsView(payslip: payslip),
      ),
    );
  }
}
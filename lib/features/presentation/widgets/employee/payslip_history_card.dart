import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employee_info_card.dart';
import 'payslip_history_item.dart';

class PayslipHistoryCard extends StatelessWidget {
  final List<Payslip> employeePayslips;
  final bool isLoadingPayslips;
  final String? payslipError;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onRefresh;
  final Function(Payslip) onViewPayslip;
  final VoidCallback onViewAll;

  const PayslipHistoryCard({
    Key? key,
    required this.employeePayslips,
    required this.isLoadingPayslips,
    this.payslipError,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onRefresh,
    required this.onViewPayslip,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmployeeInfoCard(
      icon: Icons.history,
      title: 'Payslip History',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        if (isLoadingPayslips)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 32 : 40),
              child: const CircularProgressIndicator(
                color: Color(0xFF9747FF),
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (payslipError != null)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 18),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: isTablet ? 24 : 22,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error loading payslips',
                            style: GoogleFonts.inter(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 15,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            payslipError!,
                            style: GoogleFonts.inter(
                              color: Colors.red.shade600,
                              fontSize: isTablet ? 14 : 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20,
                        vertical: isTablet ? 14 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 15 : 14,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (employeePayslips.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 32 : 40),
              child: Text(
                'No payslips found for this employee',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          )
        else ...[
          ...employeePayslips.take(5).map((payslip) => PayslipHistoryItem(
            payslip: payslip,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            onTap: () => onViewPayslip(payslip),
          )),
          if (employeePayslips.length > 5)
            Padding(
              padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
              child: Center(
                child: TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                  child: Text(
                    'View All ${employeePayslips.length} Payslips',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9747FF),
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 15,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
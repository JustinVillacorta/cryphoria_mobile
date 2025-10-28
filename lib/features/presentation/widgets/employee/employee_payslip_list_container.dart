import 'package:cryphoria_mobile/features/domain/entities/payslip.dart';
import 'package:flutter/material.dart';
import 'employee_payslip_list_header.dart';
import 'employee_payslip_empty_state.dart';
import 'employee_payslip_list_item.dart';

class EmployeePayslipListContainer extends StatelessWidget {
  final List<Payslip> payslips;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final Function(Payslip) onViewPayslip;

  const EmployeePayslipListContainer({
    Key? key,
    required this.payslips,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onViewPayslip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          EmployeePayslipListHeader(
            payslipCount: payslips.length,
            isTablet: isTablet,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (payslips.isEmpty)
            EmployeePayslipEmptyState(isTablet: isTablet)
          else
            ...payslips.map((payslip) => EmployeePayslipListItem(
              payslip: payslip,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
              onTap: () => onViewPayslip(payslip),
            )),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/payslip.dart' as payslip_entity;
import '../../Payslip/Views/payslip_details_view.dart';
import '../../../widgets/employee/employee_payslip_list_app_bar.dart';
import '../../../widgets/employee/employee_payslip_info_card.dart';
import '../../../widgets/employee/employee_payslip_list_container.dart';

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
      appBar: EmployeePayslipListAppBar(
        employee: employee,
        isTablet: isTablet,
        isDesktop: isDesktop,
        onBackPressed: () => Navigator.pop(context),
        onRefresh: onRefresh,
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
                  EmployeePayslipInfoCard(
                    employee: employee,
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  EmployeePayslipListContainer(
                    payslips: payslips,
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    onViewPayslip: (payslip) {
                      _viewPayslip(payslip, context);
                      return null;
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
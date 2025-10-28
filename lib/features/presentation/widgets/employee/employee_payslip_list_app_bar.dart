import 'package:cryphoria_mobile/features/domain/entities/employee.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeePayslipListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Employee employee;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onBackPressed;
  final VoidCallback? onRefresh;

  const EmployeePayslipListAppBar({
    Key? key,
    required this.employee,
    required this.isTablet,
    required this.isDesktop,
    required this.onBackPressed,
    this.onRefresh,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF9747FF),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: isTablet ? 26 : 24,
        ),
        onPressed: onBackPressed,
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
    );
  }
}
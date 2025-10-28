import 'package:cryphoria_mobile/features/domain/entities/employee.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeePayslipInfoCard extends StatelessWidget {
  final Employee employee;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const EmployeePayslipInfoCard({
    super.key,
    required this.employee,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

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
              color: employee.isActive 
                  ? const Color(0xFF10B981).withValues(alpha: 0.1) 
                  : Colors.red.withValues(alpha: 0.1),
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
}
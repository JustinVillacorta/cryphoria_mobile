import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeDetailTabNavigation extends StatelessWidget {
  final int currentTabIndex;
  final Function(int) onTabChanged;
  final bool isSmallScreen;
  final bool isTablet;

  const EmployeeDetailTabNavigation({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isTablet ? 16.0 : 15.0;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem('Details', 0, fontSize),
          _buildTabItem('Payroll', 1, fontSize),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, double fontSize) {
    bool isActive = currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF9747FF) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isActive ? const Color(0xFF9747FF) : const Color(0xFF6B6B6B),
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeListHeader extends StatelessWidget {
  final double sectionTitleSize;
  final bool isTablet;
  final bool isFilterExpanded;
  final VoidCallback onFilterToggle;

  const EmployeeListHeader({
    Key? key,
    required this.sectionTitleSize,
    required this.isTablet,
    required this.isFilterExpanded,
    required this.onFilterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Employee List',
          style: GoogleFonts.inter(
            fontSize: sectionTitleSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        InkWell(
          onTap: onFilterToggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF9747FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list,
                  color: const Color(0xFF9747FF),
                  size: isTablet ? 18 : 16,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  'Filter',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9747FF),
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 15 : 14,
                  ),
                ),
                SizedBox(width: isTablet ? 4 : 2),
                Icon(
                  isFilterExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF9747FF),
                  size: isTablet ? 18 : 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final bool isTablet;

  const InvoiceFilterTabs({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterTab('All'),
          SizedBox(width: isTablet ? 14 : 12),
          _buildFilterTab('Paid'),
          SizedBox(width: isTablet ? 14 : 12),
          _buildFilterTab('Pending'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 18,
          vertical: isTablet ? 10 : 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9747FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9747FF) : const Color(0xFFE5E5E5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9747FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          filter,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 15 : 14,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
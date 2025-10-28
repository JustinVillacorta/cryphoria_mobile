import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeFilterSection extends StatelessWidget {
  final List<String> departments;
  final String? selectedDepartment;
  final bool isSmallScreen;
  final bool isTablet;
  final Function(String) onDepartmentSelected;
  final VoidCallback onClearFilter;

  const EmployeeFilterSection({
    Key? key,
    required this.departments,
    required this.selectedDepartment,
    required this.isSmallScreen,
    required this.isTablet,
    required this.onDepartmentSelected,
    required this.onClearFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Department',
          style: GoogleFonts.inter(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: departments.map((department) {
              final isSelected = selectedDepartment == department;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    if (isSelected) {
                      onClearFilter();
                    } else {
                      onDepartmentSelected(department);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 18 : 16,
                      vertical: isTablet ? 10 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9747FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF9747FF) 
                            : const Color(0xFFE5E5E5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      department,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: isTablet ? 14 : 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
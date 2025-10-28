import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeFormDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final IconData icon;
  final bool isSmallScreen;
  final bool isTablet;
  final bool enabled;

  const EmployeeFormDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    required this.isSmallScreen,
    required this.isTablet,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelSize = isTablet ? 16.0 : 15.0;
    final dropdownSize = isTablet ? 15.0 : 14.0;
    final iconSize = isTablet ? 22.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: dropdownSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF9747FF),
              size: iconSize,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9747FF), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 16,
              vertical: isTablet ? 16 : 14,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF6B6B6B),
            size: isTablet ? 26 : 24,
          ),
          style: GoogleFonts.inter(
            fontSize: dropdownSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
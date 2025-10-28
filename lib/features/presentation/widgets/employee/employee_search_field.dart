import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeSearchField extends StatelessWidget {
  final bool isTablet;
  final ValueChanged<String> onSearchChanged;

  const EmployeeSearchField({
    Key? key,
    required this.isTablet,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search employees...',
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF6B6B6B),
          fontSize: isTablet ? 15 : 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: const Color(0xFF6B6B6B),
          size: isTablet ? 22 : 20,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF9747FF),
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 16 : 14,
        ),
      ),
      style: GoogleFonts.inter(
        color: const Color(0xFF1A1A1A),
        fontSize: isTablet ? 15 : 14,
        fontWeight: FontWeight.w400,
      ),
      onChanged: onSearchChanged,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isTablet;

  const InvoiceSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: isTablet ? 15 : 14,
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: 'Search invoices...',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF6B6B6B),
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: const Color(0xFF6B6B6B),
            size: isTablet ? 22 : 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 18 : 16,
            vertical: isTablet ? 18 : 16,
          ),
        ),
      ),
    );
  }
}
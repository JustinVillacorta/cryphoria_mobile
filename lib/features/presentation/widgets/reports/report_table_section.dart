import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableRowData {
  final String label;
  final String value;
  final Color? color;
  final bool isTotal;

  const TableRowData({
    required this.label,
    required this.value,
    this.color,
    this.isTotal = false,
  });
}

class ReportTableSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<TableRowData> rows;
  final bool isSmallScreen;
  final bool isTablet;

  const ReportTableSection({
    super.key,
    required this.title,
    required this.color,
    required this.rows,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 14),
        ...rows.map((row) => _buildTableRow(row, isTablet)),
      ],
    );
  }

  Widget _buildTableRow(TableRowData data, bool isTablet) {
    final fontSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              data.label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: data.isTotal ? FontWeight.w700 : FontWeight.w600,
              color: data.color ?? const Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}


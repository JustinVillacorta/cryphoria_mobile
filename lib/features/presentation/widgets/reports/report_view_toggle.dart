import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportViewToggle extends StatelessWidget {
  final bool isChartView;
  final ValueChanged<bool> onToggle;
  final bool isSmallScreen;
  final bool isTablet;

  const ReportViewToggle({
    super.key,
    required this.isChartView,
    required this.onToggle,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isTablet ? 15.0 : 14.0;
    final iconSize = isTablet ? 20.0 : 18.0;

    return Container(
      height: isTablet ? 54 : 50,
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isChartView ? const Color(0xFF9747FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isChartView ? [
                    BoxShadow(
                      color: const Color(0xFF9747FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: iconSize,
                        color: isChartView ? Colors.white : const Color(0xFF6B6B6B),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Chart View',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: isChartView ? Colors.white : const Color(0xFF6B6B6B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isChartView ? const Color(0xFF9747FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isChartView ? [
                    BoxShadow(
                      color: const Color(0xFF9747FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_chart_outlined,
                        size: iconSize,
                        color: !isChartView ? Colors.white : const Color(0xFF6B6B6B),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Table View',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: !isChartView ? Colors.white : const Color(0xFF6B6B6B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


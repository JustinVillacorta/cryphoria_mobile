import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'report_metric_card.dart';

class MetricData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const MetricData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class ReportHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<MetricData> metrics;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;

  const ReportHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.metrics,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = isDesktop ? 22.0 : isTablet ? 21.0 : 20.0;
    final subtitleSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : 22.0;
    final iconContainerSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9747FF),
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ..._buildMetricRows(metrics),
        ],
      ),
    );
  }

  List<Widget> _buildMetricRows(List<MetricData> metrics) {
    final rows = <Widget>[];
    final metricsPerRow = 2;

    for (int i = 0; i < metrics.length; i += metricsPerRow) {
      final rowMetrics = metrics.skip(i).take(metricsPerRow).toList();
      final rowChildren = <Widget>[];

      for (int j = 0; j < rowMetrics.length; j++) {
        rowChildren.add(Expanded(
          child: ReportMetricCard(
            title: rowMetrics[j].title,
            value: rowMetrics[j].value,
            color: rowMetrics[j].color,
            icon: rowMetrics[j].icon,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
          ),
        ));
        if (j < rowMetrics.length - 1) {
          rowChildren.add(SizedBox(width: isTablet ? 14 : 12));
        }
      }

      if (rowMetrics.length < metricsPerRow) {
        while (rowChildren.length < metricsPerRow * 2 - 1) {
          rowChildren.add(SizedBox(width: isTablet ? 14 : 12));
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
          if (rowChildren.length < metricsPerRow * 2 - 1) {
            rowChildren.add(SizedBox(width: isTablet ? 14 : 12));
          }
        }
      }

      rows.add(Row(children: rowChildren));

      if (i + metricsPerRow < metrics.length) {
        rows.add(SizedBox(height: isTablet ? 14 : 12));
      }
    }

    return rows;
  }
}


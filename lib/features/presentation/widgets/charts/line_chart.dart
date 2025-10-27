import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 120,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(enabled: true),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.transparent,
              barWidth: 2,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF12121200).withValues(alpha: 0.1),
                    const Color(0xFF36EBDC).withValues(alpha: 0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00F4FF),
                  const Color(0xFF5B50FF),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 3),
                FlSpot(2, 2.5),
                FlSpot(3, 4),
                FlSpot(4, 3),
                FlSpot(5, 4.5),
                FlSpot(6, 3.5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
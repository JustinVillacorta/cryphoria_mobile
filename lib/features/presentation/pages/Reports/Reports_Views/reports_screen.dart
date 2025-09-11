import 'package:flutter/material.dart';
import 'balance_sheet_screen.dart';
import 'income_statement_screen.dart';
import 'cash_flow_screen.dart';
import 'investment_performance_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int selectedTabIndex = 0;
  int selectedPeriodIndex = 0;

  final List<String> tabs = ['Financial Statements', 'Payroll Reports', 'Tax Reports'];
  final List<String> periods = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Reports',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Tab Buttons
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Period Buttons
              Row(
                children: List.generate(periods.length, (index) {
                  final isSelected = selectedPeriodIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriodIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < periods.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            periods[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Report Cards Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // First Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildReportCard(
                              'Balance Sheet',
                              'Last updated: Today',
                              const Color(0xFF3B82F6),
                              Icons.description,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReportCard(
                              'Income Statement',
                              'Last updated: Today',
                              const Color(0xFF8B5CF6),
                              Icons.bar_chart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Second Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildReportCard(
                              'Cash Flow',
                              'Last updated: Today',
                              const Color(0xFF8B5CF6),
                              Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReportCard(
                              'Investment Performance',
                              'Last updated: Today',
                              const Color(0xFFF97316),
                              Icons.show_chart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Risk Assessment Section
                      _buildRiskAssessmentSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Balance Sheet') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BalanceSheetScreen(),
            ),
          );
        } else if (title == 'Income Statement') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncomeStatementScreen(),
            ),
          );
        } else if (title == 'Cash Flow') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CashFlowScreen(),
            ),
          );
        } else if (title == 'Investment Performance') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvestmentPerformanceScreen(),
            ),
          );
        }
      },
      child: Container(
        height: 140, // Increased height to fix overflow
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '3 alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // High Risk Alert
        _buildRiskAlert(
          title: 'Decreasing Cash Flow',
          subtitle: 'Cash flow has decreased by 18% compared to last quarter.',
          recommendation: 'Review accounts receivable processes and consider implementing stricter collection policies.',
          level: 'high',
          color: Colors.red[100]!,
          iconColor: Colors.red,
          levelColor: Colors.red,
        ),
        const SizedBox(height: 12),

        // Medium Risk Alert
        _buildRiskAlert(
          title: 'Increasing Operational Expenses',
          subtitle: 'Operational expenses have increased by 12% while revenue remained flat.',
          recommendation: 'Conduct expense audit and identify areas for potential cost reduction.',
          level: 'medium',
          color: Colors.orange[100]!,
          iconColor: Colors.orange,
          levelColor: Colors.orange,
        ),
        const SizedBox(height: 12),

        // Low Risk Alert
        _buildRiskAlert(
          title: 'Debt-to-Equity Ratio Rising',
          subtitle: 'Your debt-to-equity ratio is approaching industry warning levels (currently 1.8).',
          recommendation: 'Consider equity financing options instead of taking on additional debt.',
          level: 'low',
          color: Colors.blue[100]!,
          iconColor: Colors.blue,
          levelColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildRiskAlert({
    required String title,
    required String subtitle,
    required String recommendation,
    required String level,
    required Color color,
    required Color? iconColor,
    required Color? levelColor,
  }) {
    IconData getIcon() {
      switch (level) {
        case 'high':
          return Icons.warning;
        case 'medium':
          return Icons.error_outline;
        case 'low':
          return Icons.info_outline;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor!.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                getIcon(),
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

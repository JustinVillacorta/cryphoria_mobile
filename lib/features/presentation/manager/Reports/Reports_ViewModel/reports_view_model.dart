import 'package:flutter/material.dart';

class ReportsViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int _selectedPeriodIndex = 0;
  bool _isLoading = false;

  int get selectedTabIndex => _selectedTabIndex;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  bool get isLoading => _isLoading;

  final List<String> _tabs = ['Financial Statements', 'Payroll Reports', 'Tax Reports'];
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  List<String> get tabs => _tabs;
  List<String> get periods => _periods;

  void setSelectedTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
      _loadReportData();
    }
  }

  void setSelectedPeriod(int index) {
    if (_selectedPeriodIndex != index) {
      _selectedPeriodIndex = index;
      notifyListeners();
      _loadReportData();
    }
  }

  Future<void> _loadReportData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // Risk Assessment Data
  List<RiskAlert> getRiskAlerts() {
    return [
      RiskAlert(
        title: 'Decreasing Cash Flow',
        subtitle: 'Cash flow has decreased by 18% compared to last quarter.',
        recommendation: 'Review accounts receivable processes and consider implementing stricter collection policies.',
        level: RiskLevel.high,
      ),
      RiskAlert(
        title: 'Increasing Operational Expenses',
        subtitle: 'Operational expenses have increased by 12% while revenue remained flat.',
        recommendation: 'Conduct expense audit and identify areas for potential cost reduction.',
        level: RiskLevel.medium,
      ),
      RiskAlert(
        title: 'Debt-to-Equity Ratio Rising',
        subtitle: 'Your debt-to-equity ratio is approaching industry warning levels (currently 1.8).',
        recommendation: 'Consider equity financing options instead of taking on additional debt.',
        level: RiskLevel.low,
      ),
    ];
  }

  // Report Cards Data
  List<ReportCard> getReportCards() {
    return [
      ReportCard(
        title: 'Balance Sheet',
        subtitle: 'Last updated: Today',
        color: const Color(0xFF3B82F6),
        icon: Icons.description,
      ),
      ReportCard(
        title: 'Income Statement',
        subtitle: 'Last updated: Today',
        color: const Color(0xFF8B5CF6),
        icon: Icons.bar_chart,
      ),
      ReportCard(
        title: 'Cash Flow',
        subtitle: 'Last updated: Today',
        color: const Color(0xFF8B5CF6),
        icon: Icons.trending_up,
      ),
    ];
  }

  int get alertCount => getRiskAlerts().length;
}

// Data Models
class RiskAlert {
  final String title;
  final String subtitle;
  final String recommendation;
  final RiskLevel level;

  RiskAlert({
    required this.title,
    required this.subtitle,
    required this.recommendation,
    required this.level,
  });
}

enum RiskLevel { high, medium, low }

class ReportCard {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  ReportCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

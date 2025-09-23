import 'package:cryphoria_mobile/features/presentation/widgets/payroll_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/payment_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/generate_report_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Invest/invest_main_screen.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Invest/investment_portfolio_screen.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/Views/audit_contract_main_screen.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_ViewModel/home_Viewmodel.dart';

class QuickActions extends StatefulWidget {
  final VoidCallback? onPaymentSuccess;
  
  const QuickActions({super.key, this.onPaymentSuccess});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  final ScrollController _quickActionController = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _quickActionController.addListener(() {
      if (!_quickActionController.hasClients) return;
      final maxScroll = _quickActionController.position.maxScrollExtent;
      final current = _quickActionController.offset;
      setState(() {
        _progress = (current / maxScroll).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _quickActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scroll row
        SizedBox(
          height: 100,
          child: SingleChildScrollView(
            controller: _quickActionController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionItem(
                  Icons.send,
                  'Send\nPayment',
                  Colors.blue,
                  onTap: () => showPaymentBottomSheet(context),
                ),
                const SizedBox(width: 16),
                _buildQuickActionItem(
                    Icons.receipt_long,
                    'Send\nPayroll',
                    Colors.orange,
                  onTap: () => showPayrollBottomSheet(context),
                ),
                const SizedBox(width: 16),
                _buildQuickActionItem(
                  Icons.description, 
                  'Audit\nContract', 
                  Colors.teal,
                  onTap: () => _navigateToAuditScreen(context),
                ),
                const SizedBox(width: 16),
                _buildQuickActionItem(
                  Icons.bar_chart, 
                  'Generate\nReport', 
                  Colors.green,
                  onTap: () => showGenerateReportBottomSheet(context),
                ),
                _buildQuickActionItem(
                  Icons.trending_up,
                  'Invest\nSmart',
                  Colors.purple,
                  onTap: () => _navigateToInvestScreen(context),
                ),
                const SizedBox(width: 16),
                _buildQuickActionItem(
                  Icons.pie_chart,
                  'View\nPortfolio',
                  Colors.blue,
                  onTap: () => _navigateToPortfolioScreen(context),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tiny pill-like indicator
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 40,
            height: 6,  // thickness of the bar
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double barWidth = constraints.maxWidth;
                final double indicatorWidth = 20; // pill size
                final double offset = (barWidth - indicatorWidth) * _progress;

                return Stack(
                  children: [
                    // grey background track
                    Container(
                      width: barWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // purple pill
                    Positioned(
                      left: offset,
                      child: Container(
                        width: indicatorWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Payment Bottom Sheet
  void showPaymentBottomSheet(BuildContext context) async {
    // Get the current wallet from WalletViewModel
    final walletViewModel = context.read<WalletViewModel>();
    final currentWallet = walletViewModel.wallet;
    
    if (currentWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No wallet connected. Please connect a wallet first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBottomSheet(wallet: currentWallet),
    );
    
    // If payment was successful and we have a callback, call it
    if (result != null && widget.onPaymentSuccess != null) {
      widget.onPaymentSuccess!();
    }
  }
  void showPayrollBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayrollBottomSheet(),
    );
  }
  void showGenerateReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GenerateReportBottomSheet(),
    );
  }

  void _navigateToInvestScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvestMainScreen(),
      ),
    );
  }

  void _navigateToAuditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuditContractMainScreen(),
      ),
    );
  }

  void _navigateToPortfolioScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvestmentPortfolioScreen(),
      ),
    );
  }
}
import 'package:cryphoria_mobile/features/presentation/widgets/payroll/payroll_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/payments/payment_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/reports/generate_report_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/investments/smart_invest_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/Views/audit_contract_main_screen.dart';

class QuickActions extends ConsumerStatefulWidget {
  final VoidCallback? onPaymentSuccess;
  
  const QuickActions({super.key, this.onPaymentSuccess});

  @override
  ConsumerState<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends ConsumerState<QuickActions> with SingleTickerProviderStateMixin {
  final ScrollController _quickActionController = ScrollController();
  // progress indicator removed; keep controller for potential future use
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
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
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scroll row (shows 4 items; tapping More expands to show 2 extra actions inline)
        SizedBox(
          height: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: _buildQuickActionItem(
                      Icons.send,
                      'Send\nPayment',
                      const Color(0xff9747FF),
                      onTap: () => showPaymentBottomSheet(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildQuickActionItem(
                      Icons.receipt_long,
                      'Send\nPayroll',
                      const Color(0xff9747FF),
                      onTap: () => showPayrollBottomSheet(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildQuickActionItem(
                      Icons.description,
                      'Audit\nContract',
                      const Color(0xff9747FF),
                      onTap: () => _navigateToAuditScreen(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildQuickActionItem(
                      Icons.more_horiz,
                      _expanded ? 'Less' : 'More',
                      const Color(0xff9747FF),
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Expandable area: shows extra actions below the row when expanded
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildQuickActionItem(
                        Icons.bar_chart,
                        'Generate\nReport',
                        const Color(0xff9747FF),
                        onTap: () => showGenerateReportBottomSheet(context),
                      ),
                      const SizedBox(width: 24),
                      _buildQuickActionItem(
                        Icons.trending_up,
                        'Invest\nSmart',
                        const Color(0xff9747FF),
                        onTap: () => showSmartInvestBottomSheet(context),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Removed the pill-like indicator; replaced with a single-row of 4 actions
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0x1A9747FF),
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
                size: 28,
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
    final walletState = ref.read(walletNotifierProvider);
    final currentWallet = walletState.wallet;
    
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

  void showSmartInvestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SmartInvestBottomSheet(),
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

  // (No bottom-sheet for More — inline expansion handled in the row)
}

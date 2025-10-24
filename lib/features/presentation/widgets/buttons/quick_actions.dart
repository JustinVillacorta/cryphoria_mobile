import 'package:cryphoria_mobile/features/presentation/widgets/payroll/payroll_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/payments/payment_bottom_sheet.dart';
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

  @override
  void dispose() {
    _quickActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    // Responsive sizing
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final iconSize = isDesktop ? 30.0 : isTablet ? 28.0 : 26.0;
    final containerSize = isDesktop ? 68.0 : isTablet ? 64.0 : 60.0;
    final labelFontSize = isSmallScreen ? 11.5 : isTablet ? 13.0 : 12.0;
    final itemWidth = isDesktop ? 90.0 : isTablet ? 85.0 : 80.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 14 : isTablet ? 18 : 16),

        // Single row with four actions
        SizedBox(
          height: isDesktop ? 120 : isTablet ? 115 : 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: _buildQuickActionItem(
                    Icons.send_rounded,
                    'Send\nPayment',
                    const Color(0xFF9747FF),
                    onTap: () => showPaymentBottomSheet(context),
                    containerSize: containerSize,
                    iconSize: iconSize,
                    labelFontSize: labelFontSize,
                    itemWidth: itemWidth,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildQuickActionItem(
                    Icons.receipt_long_rounded,
                    'Send\nPayroll',
                    const Color(0xFF9747FF),
                    onTap: () => showPayrollBottomSheet(context),
                    containerSize: containerSize,
                    iconSize: iconSize,
                    labelFontSize: labelFontSize,
                    itemWidth: itemWidth,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildQuickActionItem(
                    Icons.description_rounded,
                    'Audit\nContract',
                    const Color(0xFF9747FF),
                    onTap: () => _navigateToAuditScreen(context),
                    containerSize: containerSize,
                    iconSize: iconSize,
                    labelFontSize: labelFontSize,
                    itemWidth: itemWidth,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildQuickActionItem(
                    Icons.trending_up_rounded,
                    'Invest\nSmart',
                    const Color(0xFF9747FF),
                    onTap: () => showSmartInvestBottomSheet(context),
                    containerSize: containerSize,
                    iconSize: iconSize,
                    labelFontSize: labelFontSize,
                    itemWidth: itemWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
    required double containerSize,
    required double iconSize,
    required double labelFontSize,
    required double itemWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF9747FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: labelFontSize,
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPaymentBottomSheet(BuildContext context) async {
    final walletState = ref.read(walletNotifierProvider);
    final currentWallet = walletState.wallet;
    
    if (currentWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No wallet connected. Please connect a wallet first.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
}

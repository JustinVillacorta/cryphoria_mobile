import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_history_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/providers/payroll_history_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee/employee_payout_info.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee/employee_top_bar.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_details_view.dart';

class HomeEmployeeScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const HomeEmployeeScreen({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  ConsumerState<HomeEmployeeScreen> createState() => _HomeEmployeeScreenState();
}

class _HomeEmployeeScreenState extends ConsumerState<HomeEmployeeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Initializing HomeEmployeeScreen with employeeId: ${widget.employeeId}');
      ref.read(homeEmployeeNotifierProvider.notifier)
          .getDashboardData(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    // Responsive sizing
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final sectionGap = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    
    final state = ref.watch(homeEmployeeNotifierProvider);
    final notifier = ref.read(homeEmployeeNotifierProvider.notifier);
    final payrollDetailsAsync = ref.watch(payrollDetailsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF9747FF)),
              );
            }

            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B6B6B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint('Retrying dashboard data load');
                        notifier.refreshData(widget.employeeId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9747FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('Refresh triggered');
                await notifier.refreshData(widget.employeeId);
                ref.invalidate(payrollDetailsProvider);
              },
              color: const Color(0xFF9747FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmployeeTobBarWidget(
                        employeeName: state.employeeName
                      ),
                      SizedBox(height: sectionGap),
                      const WalletCard(),
                      SizedBox(height: sectionGap),
                      PayoutInfoWidget(
                        nextPayoutDate: state.nextPayoutDate,
                        frequency: state.payoutFrequency,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: sectionGap),
                      
                      // Recent Payslips Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Payslips',
                            style: GoogleFonts.inter(
                              fontSize: isDesktop ? 20 : isTablet ? 19 : 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PayslipScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF9747FF),
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      // Display recent payslips
                      payrollDetailsAsync.when(
                        data: (payrollDetails) {
                          final recentPayslips = payrollDetails.payslips.take(5).toList();
                          
                          if (recentPayslips.isEmpty) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: isSmallScreen ? 32 : 48,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: isTablet ? 56 : 48,
                                      color: const Color(0xFF6B6B6B).withOpacity(0.5),
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 16),
                                    Text(
                                      'No payslips available',
                                      style: GoogleFonts.inter(
                                        fontSize: isTablet ? 17 : 16,
                                        color: const Color(0xFF6B6B6B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            children: recentPayslips.map((payslip) {
                              return _buildPayslipCard(context, payslip, size, isSmallScreen, isTablet);
                            }).toList(),
                          );
                        },
                        loading: () => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: const Color(0xFF9747FF),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Failed to load payslips',
                                  style: GoogleFonts.inter(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: sectionGap),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPayslipCard(BuildContext context, payslip, Size size, bool isSmallScreen, bool isTablet) {
    final String date = DateFormat('MMM dd, yyyy').format(payslip.payDate);
    final String cryptoAmount = '${payslip.cryptoAmount.toStringAsFixed(4)} ${payslip.cryptocurrency ?? 'ETH'}';
    final String fiatAmount = '\$${payslip.finalNetPay.toStringAsFixed(2)} USD';

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PayslipDetailsView(payslipId: payslip.payslipId ?? ''),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 52 : 48,
                height: isTablet ? 52 : 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_outlined,
                  color: const Color(0xFF9747FF),
                  size: isTablet ? 26 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payslip.status ?? 'PENDING').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(payslip.status ?? 'PENDING'),
                            color: _getStatusColor(payslip.status ?? 'PENDING'),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (payslip.status ?? 'PENDING').toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(payslip.status ?? 'PENDING'),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cryptoAmount,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fiatAmount,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 14 : 13,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return Colors.green;
      case 'SCHEDULED':
      case 'GENERATED':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'PROCESSING':
        return Colors.orange;
      case 'PENDING':
      case 'DRAFT':
        return Colors.grey;
      case 'SENT':
        return const Color(0xFF9747FF);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return Icons.check_circle;
      case 'SCHEDULED':
      case 'GENERATED':
        return Icons.schedule;
      case 'FAILED':
        return Icons.error;
      case 'PROCESSING':
        return Icons.hourglass_empty;
      case 'PENDING':
      case 'DRAFT':
        return Icons.schedule;
      case 'SENT':
        return Icons.send;
      default:
        return Icons.help;
    }
  }

}


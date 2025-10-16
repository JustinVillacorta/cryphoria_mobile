import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/notification_view/notification_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_history_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/providers/payroll_history_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_payout_info.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_top_bar.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_header.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_lists.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_wallet_card.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_transaction_status.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                      ),
                      child: const Text('Retry'),
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
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.025,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmployeeTobBarWidget(
                        employeeName: state.employeeName,
                        onNotificationTapped: () => _navigateToNotifications(context),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      WalletCard(),
                      SizedBox(height: screenHeight * 0.02),
                      PayoutInfoWidget(
                        nextPayoutDate: state.nextPayoutDate,
                        frequency: state.payoutFrequency,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Recent Payslips Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Payslips',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1D1F),
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
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF9747FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      
                      // Display recent payslips
                      payrollDetailsAsync.when(
                        data: (payrollDetails) {
                          final recentPayslips = payrollDetails.payslips.take(5).toList();
                          
                          if (recentPayslips.isEmpty) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.06,
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
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No payslips available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
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
                              return _buildPayslipCard(context, payslip, screenWidth, screenHeight);
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Color(0xFF9747FF)),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Failed to load payslips',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
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

  Widget _buildPayslipCard(BuildContext context, payslip, double screenWidth, double screenHeight) {
    final String date = DateFormat('MMM dd, yyyy').format(payslip.payDate);
    final String cryptoAmount = '${payslip.cryptoAmount.toStringAsFixed(4)} ${payslip.cryptocurrency ?? 'ETH'}';
    final String fiatAmount = '\$${payslip.finalNetPay.toStringAsFixed(2)} USD';

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.012),
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
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  color: Color(0xFF9747FF),
                  size: 24,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
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
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(payslip.status ?? 'PENDING'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cryptoAmount,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1D1F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fiatAmount,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
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
        return Colors.purple;
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

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(),
      ),
    );
  }
} 


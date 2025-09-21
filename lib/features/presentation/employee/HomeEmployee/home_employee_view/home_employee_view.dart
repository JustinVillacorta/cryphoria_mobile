// lib/features/presentation/employee/home/views/home_employee_screen.dart
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/notification_view/notification_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/salary_transactions_view/salary_transactions_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_payout_info.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_top_bar.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_header.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_lists.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_wallet_card.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_transaction_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeEmployeeScreen extends StatefulWidget {
  final String employeeId;

  const HomeEmployeeScreen({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<HomeEmployeeScreen> createState() => _HomeEmployeeScreenState();
}

class _HomeEmployeeScreenState extends State<HomeEmployeeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeEmployeeViewModel>().getDashboardData(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Consumer<HomeEmployeeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF9747FF),
                ),
              );
            }

            if (viewModel.hasError) {
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
                      viewModel.errorMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => viewModel.refreshData(widget.employeeId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9747FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshData(widget.employeeId),
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
                        employeeName: viewModel.toString(),
                        onNotificationTapped: () => _navigateToNotifications(context),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      EmployeeWalletCardWidget(
                        balance: viewModel.walletDisplayBalance,
                        convertedBalance: viewModel.convertedDisplayBalance,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      PayoutInfoWidget(
                        nextPayoutDate: viewModel.nextPayoutDate,
                        frequency: viewModel.payoutFrequency,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TransactionListHeaderWidget(
                        onViewAllTapped: () => _navigateToAllTransactions(context),
                        isTablet: isTablet,
                      ),
                      SizedBox(height: screenHeight * 0.016),
                      if (viewModel.recentTransactions.isEmpty)
                        _buildEmptyTransactionsState(screenHeight)
                      else
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: viewModel.recentTransactions
                              .map<Widget>(
                                (dynamic transaction) => TransactionItemWidget(
                              transaction: Transaction.fromMap(transaction),
                              isTablet: isTablet,
                            ),
                          )
                              .toList(),
                        ),
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

  Widget _buildEmptyTransactionsState(double screenHeight) {
    return Container(
      height: screenHeight * 0.2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your recent transactions will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(),
      ),
    );
  }

  void _navigateToAllTransactions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalaryTransactionsScreen(),
      ),
    );
  }
}
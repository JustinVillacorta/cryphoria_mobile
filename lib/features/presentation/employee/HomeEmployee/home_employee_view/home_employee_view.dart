import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/notification_view/notification_view.dart';
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
                      WalletCard(
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      PayoutInfoWidget(
                        nextPayoutDate: state.nextPayoutDate,
                        frequency: state.payoutFrequency,
                        isTablet: isTablet,
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
  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(),
      ),
    );
  }
}

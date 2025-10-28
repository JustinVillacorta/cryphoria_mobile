import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/payroll/payroll_bottom_sheet.dart';
import '../../../widgets/payroll/payroll_summary_cards_row.dart';
import '../../../widgets/payroll/payroll_error_banner.dart';
import '../../../widgets/payroll/employee_payroll_card.dart';
import '../../../widgets/payroll/payroll_empty_state.dart';
import '../../../widgets/payroll/employee_details_bottom_sheet.dart';

class PayrollManagementScreen extends ConsumerStatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  ConsumerState<PayrollManagementScreen> createState() => _ExistingPayrollManagementScreenState();
}

class _ExistingPayrollManagementScreenState extends ConsumerState<PayrollManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> employeePayrollList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadManagerPayrollData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadManagerPayrollData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ref.read(dioClientProvider).dio.get('/api/manager/payroll/employees/');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          employeePayrollList = List<Map<String, dynamic>>.from(response.data['employees'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load payroll data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading payroll data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _debugWalletFetching() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Debugging wallet fetching...'),
            ],
          ),
        ),
      );

      final getManagerTeamWithWalletsUseCase = ref.read(getManagerTeamWithWalletsUseCaseProvider);
      final employees = await getManagerTeamWithWalletsUseCase.execute();

      if (mounted) Navigator.pop(context);

      final debugResults = <String>[];
      debugResults.add('=== WALLET DEBUG RESULTS ===');
      debugResults.add('Total employees: ${employees.length}');
      debugResults.add('');

      for (final employee in employees) {
        debugResults.add('Employee: ${employee.displayName}');
        debugResults.add('  - User ID: ${employee.userId}');
        debugResults.add('  - Email: ${employee.email}');
        debugResults.add('  - Current Wallet: ${employee.payrollInfo?.employeeWallet ?? "NULL"}');
        debugResults.add('');
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wallet Debug Results'),
            content: SingleChildScrollView(
              child: Text(
                debugResults.join('\n'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Print to Console'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payroll Management',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'refresh') {
                _loadManagerPayrollData();
              } else if (value == 'debug_wallets') {
                _debugWalletFetching();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'debug_wallets',
                child: ListTile(
                  leading: Icon(Icons.bug_report),
                  title: Text('Debug Wallet Fetching'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9747FF),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF9747FF),
          tabs: const [
            Tab(text: 'Employee List'),
            Tab(text: 'Payroll History'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isLoading && employeePayrollList.isNotEmpty)
            PayrollSummaryCardsRow(
              totalEmployees: employeePayrollList.length,
              activeEmployees: employeePayrollList.where((e) => e['is_active'] == true).length,
              totalPaid: _calculateTotalPaid(),
            ),
          if (errorMessage != null)
            PayrollErrorBanner(
              errorMessage: errorMessage!,
              onRefresh: _loadManagerPayrollData,
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeeList(),
                _buildPayrollHistory(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPayrollBottomSheet,
        backgroundColor: const Color(0xFF9747FF),
        label: const Text('Process Payroll', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.payment, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (employeePayrollList.isEmpty) {
      return PayrollEmptyState(
        title: 'No employees found',
        subtitle: 'Add employees to your team to manage payroll',
        icon: Icons.people_outline,
        onRefresh: _loadManagerPayrollData,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employeePayrollList.length,
      itemBuilder: (context, index) {
        final employee = employeePayrollList[index];
        return EmployeePayrollCard(
          employee: employee,
          onTap: () => _showEmployeeDetails(employee),
        );
      },
    );
  }

  Widget _buildPayrollHistory() {
    return const PayrollEmptyState(
      title: 'Payroll History',
      subtitle: 'View detailed payroll history for all employees',
      icon: Icons.history,
    );
  }

  double _calculateTotalPaid() {
    return employeePayrollList.fold(0.0, (sum, employee) {
      final payrollSummary = employee['payroll_summary'] ?? {};
      return sum + (payrollSummary['total_paid_usd'] ?? 0).toDouble();
    });
  }

  void _showPayrollBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PayrollBottomSheet(),
    ).then((_) {
      _loadManagerPayrollData();
    });
  }

  void _showEmployeeDetails(Map<String, dynamic> employee) async {
    try {
      final response = await ref.read(dioClientProvider).dio.post(
        '/api/manager/payroll/employee-details/',
        data: {'employee_id': employee['employee_id']},
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        _showEmployeeDetailsBottomSheet(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load employee details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading employee details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEmployeeDetailsBottomSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmployeeDetailsBottomSheet(data: data),
    );
  }
}
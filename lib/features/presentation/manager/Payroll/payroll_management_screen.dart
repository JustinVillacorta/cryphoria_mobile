import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../dependency_injection/riverpod_providers.dart';
import '../../widgets/payroll/payroll_bottom_sheet.dart';

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
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Employees',
                      employeePayrollList.length.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Active Employees',
                      employeePayrollList.where((e) => e['is_active'] == true).length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Paid',
                      '\$${_calculateTotalPaid().toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red[700], fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: _loadManagerPayrollData,
                  ),
                ],
              ),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (employeePayrollList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add employees to your team to manage payroll',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadManagerPayrollData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9747FF)),
              child: const Text('Refresh', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employeePayrollList.length,
      itemBuilder: (context, index) {
        final employee = employeePayrollList[index];
        return _buildEmployeeCard(employee);
      },
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final payrollSummary = employee['payroll_summary'] ?? {};
    final isActive = employee['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEmployeeDetails(employee),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['full_name'] ?? employee['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${employee['department'] ?? 'General'} • ${employee['email'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.attach_money,
                    'Total Paid: \$${(payrollSummary['total_paid_usd'] ?? 0).toStringAsFixed(2)}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.pending,
                    'Pending: \$${(payrollSummary['pending_amount_usd'] ?? 0).toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.receipt,
                    'Entries: ${payrollSummary['total_entries'] ?? 0}',
                  ),
                  const Spacer(),
                  if (payrollSummary['last_payment_date'] != null)
                    Text(
                      'Last: ${_formatDate(payrollSummary['last_payment_date'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildPayrollHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Payroll History',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View detailed payroll history for all employees',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  double _calculateTotalPaid() {
    return employeePayrollList.fold(0.0, (sum, employee) {
      final payrollSummary = employee['payroll_summary'] ?? {};
      return sum + (payrollSummary['total_paid_usd'] ?? 0).toDouble();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['employee_details']?['full_name'] ?? 'Employee Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employee Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Name', data['employee_details']?['full_name'] ?? 'N/A'),
                    _buildDetailRow('Email', data['employee_details']?['email'] ?? 'N/A'),
                    _buildDetailRow('Department', data['employee_details']?['department'] ?? 'N/A'),
                    _buildDetailRow('Employee ID', data['employee_details']?['employee_number'] ?? 'N/A'),

                    const SizedBox(height: 24),

                    const Text(
                      'Payroll Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Total Entries', '${data['payroll_statistics']?['total_entries'] ?? 0}'),
                    _buildDetailRow('Completed Payments', '${data['payroll_statistics']?['completed_payments'] ?? 0}'),
                    _buildDetailRow('Scheduled Payments', '${data['payroll_statistics']?['scheduled_payments'] ?? 0}'),
                    _buildDetailRow('Failed Payments', '${data['payroll_statistics']?['failed_payments'] ?? 0}'),
                    _buildDetailRow('Total Paid (USD)', '\$${(data['payroll_statistics']?['total_paid_usd'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailRow('Total Pending (USD)', '\$${(data['payroll_statistics']?['total_pending_usd'] ?? 0).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
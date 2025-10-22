import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/payslip.dart' as payslip_entity;
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../Payslip/Views/payslip_details_view.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Payslip data
  List<payslip_entity.Payslip> employeePayslips = [];
  bool isLoadingPayslips = true;
  String? payslipError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // Load employee payslips
    Future.microtask(() => _loadEmployeePayslips());
  }

  Future<void> _loadEmployeePayslips() async {
    try {
      setState(() {
        isLoadingPayslips = true;
        payslipError = null;
      });

      final payslipRepository = ref.read(payslipRepositoryProvider);
      final payslips = await payslipRepository.getUserPayslips(
        employeeId: widget.employee.userId,
      );

      if (mounted) {
        setState(() {
          employeePayslips = payslips;
          isLoadingPayslips = false;
        });
      }
    } catch (e) {
      print('Error loading employee payslips: $e');
      if (mounted) {
        setState(() {
          payslipError = 'Failed to load payslips: ${e.toString()}';
          isLoadingPayslips = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom App Bar with Employee Header
          _buildEmployeeHeader(),
          // Tab Navigation
          _buildTabNavigation(),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildPayrollTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9747FF), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            children: [
              // Top Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Employee Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => _showDeleteDialog(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => _editEmployee(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Employee Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile_placeholder.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Active status on same line
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.employee.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.employee.position ?? 'Employee',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.employee.employeeCode,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Contact Info
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.employee.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.business_outlined, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.employee.department ?? 'General',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildTabNavigation() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem('Details', 0),
          _buildTabItem('Payroll', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF9747FF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFF9747FF) : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInformationCard(),
          const SizedBox(height: 20),
          _buildEmploymentInformationCard(),
          // Benefits section removed per requirements
        ],
      ),
    );
  }

  Widget _buildPersonalInformationCard() {
    return _buildCard(
      icon: Icons.person_outline,
      title: 'Personal Information',
      children: [
        _buildInfoRow('Email', widget.employee.email),
        _buildInfoRow('Username', widget.employee.username),
        _buildInfoRow('Employee ID', widget.employee.userId),
        _buildInfoRow('Role', widget.employee.role),
        _buildInfoRow('Status', widget.employee.isActive ? 'Active' : 'Inactive'),
        _buildInfoRow('Joined Date', widget.employee.createdAt.toString().split(' ')[0]),
      ],
    );
  }

  Widget _buildEmploymentInformationCard() {
    return _buildCard(
      icon: Icons.work_outline,
      title: 'Employment Information',
      children: [
        // Removed Basic Salary, Start Date, Employment Type, Payment Schedule
        _buildInfoRow('Department', widget.employee.department ?? 'General'),
        _buildInfoRow('Position', widget.employee.position ?? 'Employee'),
      ],
    );
  }

  // Benefits card removed per requirements

  Widget _buildPayrollTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Payslip Summary
          _buildPayslipSummaryCard(),
          const SizedBox(height: 20),
          // Payment History
          _buildPayslipHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildPayslipSummaryCard() {
    // Calculate summary from latest payslip
    final latestPayslip = employeePayslips.isNotEmpty ? employeePayslips.first : null;
    final totalPayslips = employeePayslips.length;
    final totalPaid = employeePayslips
        .where((p) => p.status == payslip_entity.PayslipStatus.paid)
        .fold(0.0, (sum, payslip) => sum + payslip.finalNetPay);

    return _buildCard(
      title: 'Payslip Summary',
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      children: [
        if (latestPayslip != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${latestPayslip.finalNetPay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Latest Net Pay',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Base Salary',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${latestPayslip.baseSalary.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Deductions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${latestPayslip.totalDeductions.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Pay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '\$${latestPayslip.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Deduction Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDeductionRow('Tax', '\$${latestPayslip.taxDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Insurance', '\$${latestPayslip.insuranceDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Retirement', '\$${latestPayslip.retirementDeduction.toStringAsFixed(2)}'),
          _buildDeductionRow('Others', '\$${latestPayslip.otherDeductions.toStringAsFixed(2)}'),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No payslips found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Payslips will appear here once generated',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        // Summary stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$totalPayslips',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const Text(
                    'Total Payslips',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    '\$${totalPaid.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const Text(
                    'Total Paid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayslipHistoryCard() {
    return _buildCard(
      title: 'Payslip History',
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      children: [
        if (isLoadingPayslips)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (payslipError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error loading payslips',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  payslipError!,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadEmployeePayslips,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (employeePayslips.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No payslips found for this employee',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...employeePayslips.take(5).map((payslip) => _buildPayslipHistoryItem(payslip)),
        
        if (employeePayslips.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: TextButton(
                onPressed: () => _viewAllPayslips(),
                child: Text(
                  'View All ${employeePayslips.length} Payslips',
                  style: const TextStyle(
                    color: Color(0xFF9747FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPayslipHistoryItem(payslip_entity.Payslip payslip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pay Date: ${DateFormat('MMM dd, yyyy').format(payslip.payDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payslip.statusEnum).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payslip.statusEnum.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(payslip.statusEnum),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${payslip.finalNetPay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _viewPayslip(payslip),
                child: const Text(
                  'View',
                  style: TextStyle(
                    color: Color(0xFF9747FF),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(payslip_entity.PayslipStatus status) {
    switch (status) {
      case payslip_entity.PayslipStatus.draft:
        return Colors.orange;
      case payslip_entity.PayslipStatus.generated:
        return Colors.blue;
      case payslip_entity.PayslipStatus.sent:
        return Colors.purple;
      case payslip_entity.PayslipStatus.paid:
        return Colors.green;
      case payslip_entity.PayslipStatus.cancelled:
        return Colors.red;
      case payslip_entity.PayslipStatus.processing:
        return Colors.amber;
      case payslip_entity.PayslipStatus.failed:
        return Colors.red;
      case payslip_entity.PayslipStatus.pending:
        return Colors.grey;
    }
  }



  Widget _buildCard({
    IconData? icon,
    required String title,
    TextStyle? titleStyle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF9747FF), size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: titleStyle ?? const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildBenefitRow removed with Benefits section

  Widget _buildDeductionRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Remove Employee'),
              content: Text('Are you sure you want to remove ${widget.employee.displayName} from the team?'),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);

                          try {
                            // Get the EmployeeViewModel from the provider
                            final employeeViewModel = ref.read(employeeViewModelProvider.notifier);
                            await employeeViewModel.removeEmployeeFromTeam(widget.employee.email);
                            
                            // Close dialog first
                            Navigator.pop(context);
                            
                            // Small delay to ensure first navigation completes
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            // Navigate back to employee list
                            Navigator.pop(context);
                          } catch (e) {
                            // Close dialog first
                            Navigator.pop(context);
                            
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove employee: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editEmployee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit employee functionality coming soon')),
    );
  }

  void _viewPayslip(payslip_entity.Payslip payslip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayslipDetailsView(payslip: payslip),
      ),
    );
  }

  void _viewAllPayslips() {
    // Navigate to a full payslip list screen for this employee
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing all ${employeePayslips.length} payslips for ${widget.employee.displayName}'),
      ),
    );
    // TODO: Implement navigation to full payslip list screen
  }

 
}

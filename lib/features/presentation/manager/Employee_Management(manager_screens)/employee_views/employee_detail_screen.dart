import 'package:flutter/material.dart';
import '../../../../domain/entities/employee.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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
                _buildDocumentsTab(),
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
                        Text(
                          widget.employee.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
          _buildTabItem('Documents', 2),
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
          const SizedBox(height: 20),
          _buildBenefitsCard(),
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
        _buildInfoRow('Basic Salary', widget.employee.payrollInfo != null 
            ? '${widget.employee.payrollInfo!.salaryAmount.toStringAsFixed(2)} ${widget.employee.payrollInfo!.salaryCurrency}'
            : 'Not set'),
        _buildInfoRow('Start Date', widget.employee.payrollInfo?.startDate.toString().split(' ')[0] ?? 'Not set'),
        _buildInfoRow('Employment Type', 'Full-time'),
        _buildInfoRow('Payment Schedule', widget.employee.payrollInfo?.paymentFrequency ?? 'Not set'),
        _buildInfoRow('Department', widget.employee.department ?? 'General'),
        _buildInfoRow('Position', widget.employee.position ?? 'Employee'),
      ],
    );
  }

  Widget _buildBenefitsCard() {
    return _buildCard(
      icon: Icons.favorite_outline,
      title: 'Benefits',
      children: [
        _buildBenefitRow('Health Insurance', 'Enrolled'),
        _buildBenefitRow('Retirement Plan', 'Enrolled'),
      ],
    );
  }

  Widget _buildPayrollTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPayPeriodCard(),
          const SizedBox(height: 20),
          _buildPaymentHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentPayPeriodCard() {
    return _buildCard(
      title: 'Current Pay Period',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '₱3250.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Net Pay',
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
                    'Basic Pay',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    '₱3500.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overtime',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    '₱3500.00',
                    style: TextStyle(
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
                    'Allowances',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    '₱500.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
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
                  const Text(
                    '-₱500.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
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
        _buildDeductionRow('SSS', '₱300.00'),
        _buildDeductionRow('PhilHealth', '₱150.00'),
        _buildDeductionRow('Pag-IBIG', '₱100.00'),
        _buildDeductionRow('Tax', '₱18.00'),
        _buildDeductionRow('Others', '₱0.00'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _downloadPayslip(),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Payslip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendPayslip(),
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Send Payslip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9747FF),
                  side: const BorderSide(color: Color(0xFF9747FF)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryCard() {
    return _buildCard(
      title: 'Payment History',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      children: [
        _buildPaymentHistoryItem(
          'May 18-31, 2023',
          'May 31, 2023',
          '₱3250.00',
        ),
        _buildPaymentHistoryItem(
          'May 1-15, 2023',
          'May 15, 2023',
          '₱3250.00',
        ),
        _buildPaymentHistoryItem(
          'April 16-30, 2023',
          'April 30, 2023',
          '₱3250.00',
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildDocumentItem(
            'Employment Contract',
            'Uploaded on • 2018-03-10',
            Icons.description_outlined,
          ),
          _buildDocumentItem(
            'NDA Agreement',
            'Uploaded on • 2018-03-10',
            Icons.description_outlined,
          ),
          _buildDocumentItem(
            'Tax Forms',
            'Uploaded on • 2019-01-15',
            Icons.description_outlined,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _uploadNewDocument(),
              icon: const Icon(Icons.add),
              label: const Text('Upload New Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9747FF),
                side: const BorderSide(color: Color(0xFF9747FF)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildBenefitRow(String benefit, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            benefit,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPaymentHistoryItem(String period, String date, String amount) {
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
                  period,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _viewPayslip(),
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

  Widget _buildDocumentItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9747FF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _viewDocument(),
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
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Employee'),
          content: Text('Are you sure you want to delete ${widget.employee.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employee deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _editEmployee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit employee functionality coming soon')),
    );
  }

  void _downloadPayslip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading payslip...')),
    );
  }

  void _sendPayslip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending payslip via email...')),
    );
  }

  void _viewPayslip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening payslip viewer...')),
    );
  }

  void _uploadNewDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document upload coming soon...')),
    );
  }

  void _viewDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening document viewer...')),
    );
  }
}

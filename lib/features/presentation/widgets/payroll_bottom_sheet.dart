import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dependency_injection/riverpod_providers.dart';
import '../../domain/entities/employee.dart';


class PayrollBottomSheet extends ConsumerStatefulWidget {
  const PayrollBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<PayrollBottomSheet> createState() => _PayrollBottomSheetState();
}

class _PayrollBottomSheetState extends ConsumerState<PayrollBottomSheet> {
  String payrollType = 'Regular Payroll';
  DateTime payPeriodStart = DateTime(2025, 9, 7);
  DateTime payPeriodEnd = DateTime(2025, 9, 7);
  DateTime payDate = DateTime(2025, 9, 7);
  bool isProcessing = false;
  String? errorMessage;

  final List<PayrollEmployee> employees = [
    PayrollEmployee(
      name: 'Sarah Johnson',
      role: 'Senior Accountant',
      amount: 3250.00,
      paymentWallet: 'MetaMask (0+7hC7...87SF)',
      isSelected: true,
    ),
    PayrollEmployee(
      name: 'Michael Chen',
      role: 'Financial Analyst',
      amount: 2800.00,
      paymentWallet: 'Coinbase (0+264E...Fc30)',
      isSelected: true,
    ),
    PayrollEmployee(
      name: 'Emily Rodriguez',
      role: 'Payroll Specialist',
      amount: 2450.00,
      paymentWallet: 'No wallet connected',
      isSelected: false,
      hasWarning: true,
    ),
    PayrollEmployee(
      name: 'David Kim',
      role: 'Tax Consultant',
      amount: 2880.00,
      paymentWallet: '',
      isSelected: false,
    ),
  ];

  double get totalAmount => employees
      .where((e) => e.isSelected)
      .map((e) => e.amount)
      .fold(0.0, (sum, amount) => sum + amount);

  int get selectedCount => employees.where((e) => e.isSelected).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Text(
                  'Process Payroll',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Process automated batch payments for your employees with calculated deductions and taxes.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Payroll Type
                  Text(
                    'Payroll Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(payrollType),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Pay Period and Date Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay Period Start',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text('mm/dd/yyyy'),
                                  Spacer(),
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay Period End',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text('mm/dd/yyyy'),
                                  Spacer(),
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Pay Date
                  Text(
                    'Pay Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text('2025-09-07'),
                        Spacer(),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Employees Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Employees to be paid',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$selectedCount selected',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Employee List
                  ...employees.map((employee) => employeeCard(employee)).toList(),

                  SizedBox(height: 24),

                  // Total
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Crypto Payment Notice
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crypto Payment Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cryptocurrency payments will be sent to the employees\' selected wallet address. Transactions may take 10-30 minutes to confirm on the blockchain.',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Important Notice
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.amber[700], size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[800],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Processing payroll will initiate cryptocurrency transfers to selected employees. Please ensure all wallet addresses are correct before proceeding.',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message display
          if (errorMessage != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processing Error',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom Actions
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedCount > 0 && !isProcessing ? _processPayroll : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Process Payroll',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayroll() async {
    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    try {
      final processPayrollUseCase = ref.read(processPayrollUseCaseProvider);

      // Convert selected employees to PayrollEmployee list
      final selectedEmployees = employees
          .where((e) => e.isSelected)
          .map((e) => PayrollEmployee(
                employeeId: e.name.toLowerCase().replaceAll(' ', '_'), // Simple ID generation
                employeeName: e.name,
                amount: e.amount,
                currency: 'USDC', // Default currency
                walletAddress: e.paymentWallet.isNotEmpty && !e.paymentWallet.contains('No wallet')
                    ? e.paymentWallet.split('(').last.replaceAll(')', '').replaceAll('...', '')
                    : null,
              ))
          .toList();

      final request = PayrollBatchRequest(
        payrollType: payrollType,
        payPeriodStart: payPeriodStart,
        payPeriodEnd: payPeriodEnd,
        payDate: payDate,
        employees: selectedEmployees,
      );

      final result = await processPayrollUseCase.execute(request);

      setState(() {
        isProcessing = false;
      });

      // Show success message with details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payroll processed successfully! ${result.processedEmployees}/${result.totalEmployees} payments completed.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Close the bottom sheet
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        isProcessing = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process payroll: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget employeeCard(PayrollEmployee employee) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: employee.isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: employee.isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: employee.isSelected ? Colors.blue[50] : Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: employee.isSelected,
            onChanged: employee.hasWarning ? null : (value) {
              setState(() {
                employee.isSelected = value ?? false;
              });
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  employee.role,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (employee.paymentWallet.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Payment Wallet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (employee.hasWarning) ...[
                        SizedBox(width: 8),
                        Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    employee.paymentWallet,
                    style: TextStyle(
                      color: employee.hasWarning ? Colors.orange : Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '\$${employee.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollEmployee {
  final String name;
  final String role;
  final double amount;
  final String paymentWallet;
  bool isSelected;
  final bool hasWarning;

  PayrollEmployee({
    required this.name,
    required this.role,
    required this.amount,
    required this.paymentWallet,
    this.isSelected = false,
    this.hasWarning = false,
  });
}


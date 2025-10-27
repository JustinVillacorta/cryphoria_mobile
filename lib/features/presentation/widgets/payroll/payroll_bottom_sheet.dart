import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../dependency_injection/riverpod_providers.dart';
import '../../../domain/entities/create_payslip_request.dart';
import '../../../domain/entities/employee.dart' as domain_employee;
import '../../../../core/network/dio_client.dart';
import '../../../domain/repositories/payslip_repository.dart';
import '../skeletons/payroll_employees_skeleton.dart';
import 'background_processing_dialog.dart';

class PayrollBottomSheet extends ConsumerStatefulWidget {
  const PayrollBottomSheet({super.key});

  @override
  ConsumerState<PayrollBottomSheet> createState() => _PayrollBottomSheetState();
}

class _PayrollBottomSheetState extends ConsumerState<PayrollBottomSheet> {
  String payrollType = 'Regular Payroll';
  DateTime payPeriodStart = DateTime(2025, 9, 7);
  DateTime payPeriodEnd = DateTime(2025, 9, 7);
  DateTime payDate = DateTime(2025, 9, 7);

  List<EmployeePayrollInfo> employeePayrollList = [];
  bool isLoadingEmployees = true;
  String? employeeLoadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _loadEmployees();
      }
    });
  }

  @override
  void dispose() {
    for (final employeePayroll in employeePayrollList) {
      employeePayroll.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;

    setState(() {
      isLoadingEmployees = true;
      employeeLoadError = null;
    });

    try {
      final getManagerTeamWithWalletsUseCase = ref.read(getManagerTeamWithWalletsUseCaseProvider);

      final employees = await getManagerTeamWithWalletsUseCase.execute();

      await _createMissingPayrollEntries(employees);

      final updatedEmployees = await getManagerTeamWithWalletsUseCase.execute();

      for (final employeePayroll in employeePayrollList) {
        employeePayroll.dispose();
      }

      employeePayrollList = updatedEmployees.map((employee) {
        return EmployeePayrollInfo(
          employee: employee,
          isSelected: false,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        isLoadingEmployees = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoadingEmployees = false;
        employeeLoadError = e.toString();
      });
    }
  }

  Future<void> _createMissingPayrollEntries(List<domain_employee.Employee> employees) async {


    return;
  }

  double get totalAmount => employeePayrollList
      .where((e) => e.isSelected)
      .map((e) => double.tryParse(e.salaryController.text) ?? 0.0)
      .fold(0.0, (sum, amount) => sum + amount);

  int get selectedCount => employeePayrollList.where((e) => e.isSelected).length;


  Future<void> _processPayroll() async {
    if (!mounted) return;

    try {
      final selectedEmployees = employeePayrollList.where((e) => e.isSelected).toList();

      if (selectedEmployees.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one employee')),
        );
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final payrollEntries = <Map<String, dynamic>>[];
      final employeeWalletMap = <String, String>{};

      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;

        try {

          final response = await ref.read(dioClientProvider).dio.post('/api/payroll/create/', data: {
            'employee_id': employee.userId,
            'employee_name': employee.displayName,
            'salary_amount': salaryAmount,
            'salary_currency': 'USD',
            'payment_frequency': 'MONTHLY',
            'start_date': payDate.toIso8601String().split('T')[0],
          });

          if (response.statusCode == 200 && response.data['success'] == true) {
            payrollEntries.add(response.data['payroll_entry']);
            final employeeWallet = response.data['payroll_entry']['employee_wallet'];
            employeeWalletMap[employee.userId] = employeeWallet;
          } else {
            debugPrint('Failed to get employee wallet for ${employee.userId}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error fetching employee wallet for ${employee.userId}: $e');
        }
      }


      final payslipRepository = ref.read(payslipRepositoryProvider);
      int successCount = 0;

      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;

        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;

        final employeeWallet = employeeWalletMap[employee.userId] ?? employee.payrollInfo?.employeeWallet;


        final payslipRequest = CreatePayslipRequest(
          employeeId: employee.userId,
          employeeName: employee.displayName,
          employeeEmail: employee.email,
          employeeWallet: employeeWallet,
          department: employee.department,
          position: employee.position,
          salaryAmount: salaryAmount,
          salaryCurrency: 'USD',
          cryptocurrency: 'ETH',
          payPeriodStart: '${payPeriodStart.year}-${payPeriodStart.month.toString().padLeft(2, '0')}-${payPeriodStart.day.toString().padLeft(2, '0')}',
          payPeriodEnd: '${payPeriodEnd.year}-${payPeriodEnd.month.toString().padLeft(2, '0')}-${payPeriodEnd.day.toString().padLeft(2, '0')}',
          payDate: '${payDate.year}-${payDate.month.toString().padLeft(2, '0')}-${payDate.day.toString().padLeft(2, '0')}',
          taxDeduction: 0.0,
          insuranceDeduction: 0.0,
          retirementDeduction: 0.0,
          otherDeductions: 0.0,
          overtimePay: 0.0,
          bonus: 0.0,
          allowances: 0.0,
          notes: 'Generated from mobile payroll processing - $payrollType',
        );

        try {
          await payslipRepository.createPayslip(payslipRequest);
          successCount++;
        } catch (e) {
          debugPrint('Error creating payslip for ${employee.displayName}: $e');
        }

        if (!mounted) break;
      }

      if (!mounted) return;

      Navigator.pop(context);

      if (successCount == selectedEmployees.length) {
        Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully processed payroll for $successCount employees'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Processed $successCount of ${selectedEmployees.length} employees'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payroll: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayrollNow() async {
    if (!mounted) return;

    try {
      final selectedEmployees = employeePayrollList.where((e) => e.isSelected).toList();

      if (selectedEmployees.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one employee')),
        );
        return;
      }

      if (!mounted) return;

      final dioClient = ref.read(dioClientProvider);
      final payslipRepository = ref.read(payslipRepositoryProvider);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PayrollLoadingDialog(
          selectedEmployees: selectedEmployees,
          dioClient: dioClient,
          payslipRepository: payslipRepository,
        ),
      );

      final entryIds = <String>[];
      final employeeWalletMap = <String, String>{};

      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;

        try {

          final response = await dioClient.dio.post('/api/payroll/create/', data: {
            'employee_id': employee.userId,
            'employee_name': employee.displayName,
            'salary_amount': salaryAmount,
            'salary_currency': 'USD',
            'payment_frequency': 'MONTHLY',
            'start_date': payDate.toIso8601String().split('T')[0],
          });


          if (response.statusCode == 200 && response.data['success'] == true) {
            final entryId = response.data['payroll_entry']['entry_id'];
            final employeeWallet = response.data['payroll_entry']['employee_wallet'];
            entryIds.add(entryId);
            employeeWalletMap[employee.userId] = employeeWallet;
          } else {
            debugPrint('Failed to create payroll entry for ${employee.userId}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error creating payroll entry for ${employee.userId}: $e');
        }
      }

      if (entryIds.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create payroll entries. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int processedEntries = 0;

      for (final entryId in entryIds) {
        try {

          final response = await dioClient.dio.post('/api/payroll/process/', data: {
            'entry_id': entryId,
          });


          if (response.statusCode == 200) {
            processedEntries++;

            if (response.data['success'] == false) {
              debugPrint('Payroll processing failed for entry $entryId');
            }
          } else {
            debugPrint('Failed to process payroll entry $entryId: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error processing payroll entry $entryId: $e');
        }
      }

      if (!mounted) return;

      int payslipSuccessCount = 0;
      int paidPayslipCount = 0;
      final createdPayslipIds = <String>[];


      if (processedEntries > 0) {

        for (final employeePayroll in selectedEmployees) {
          if (!mounted) break;

          final employee = employeePayroll.employee;

          final salaryText = employeePayroll.salaryController.text.trim();
          final salaryAmount = double.tryParse(salaryText) ?? 0.0;

          final employeeWallet = employeeWalletMap[employee.userId] ?? employee.payrollInfo?.employeeWallet;


          final payslipRequest = CreatePayslipRequest(
            employeeId: employee.userId,
            employeeName: employee.displayName,
            employeeEmail: employee.email,
            employeeWallet: employeeWallet,
            department: employee.department,
            position: employee.position,
            salaryAmount: salaryAmount,
            salaryCurrency: 'USD',
            cryptocurrency: 'ETH',
            payPeriodStart: '${payPeriodStart.year}-${payPeriodStart.month.toString().padLeft(2, '0')}-${payPeriodStart.day.toString().padLeft(2, '0')}',
            payPeriodEnd: '${payPeriodEnd.year}-${payPeriodEnd.month.toString().padLeft(2, '0')}-${payPeriodEnd.day.toString().padLeft(2, '0')}',
            payDate: '${payDate.year}-${payDate.month.toString().padLeft(2, '0')}-${payDate.day.toString().padLeft(2, '0')}',
            taxDeduction: 0.0,
            insuranceDeduction: 0.0,
            retirementDeduction: 0.0,
            otherDeductions: 0.0,
            overtimePay: 0.0,
            bonus: 0.0,
            allowances: 0.0,
            notes: 'Generated from mobile payroll processing - $payrollType (Sent Now)',
          );

          try {
            final createdPayslip = await payslipRepository.createPayslip(payslipRequest);
            final payslipIdForPayment = createdPayslip.payslipId ?? createdPayslip.id;
            if (payslipIdForPayment != null) {
              createdPayslipIds.add(payslipIdForPayment);
            }
            payslipSuccessCount++;
          } catch (e) {
            debugPrint('Error creating payslip for ${employee.displayName} in background: $e');
          }
        }

        paidPayslipCount = createdPayslipIds.length;
      } else {
      }

      if (!mounted) return;

      Navigator.pop(context);

      if (processedEntries == entryIds.length && payslipSuccessCount == selectedEmployees.length && paidPayslipCount == createdPayslipIds.length) {
        Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully sent payroll and marked payslips as paid for $processedEntries employees'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (processedEntries > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sent payroll for $processedEntries out of ${entryIds.length} employees, created $payslipSuccessCount payslips, marked $paidPayslipCount as paid'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send payroll. Payment transaction failed. Please check your wallet balance and try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending payroll: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Future<void> _selectPayPeriodStart(BuildContext context) async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: payPeriodStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9747FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != payPeriodStart && mounted) {
      setState(() {
        payPeriodStart = picked;
      });
    }
  }

  Future<void> _selectPayPeriodEnd(BuildContext context) async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: payPeriodEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9747FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != payPeriodEnd && mounted) {
      setState(() {
        payPeriodEnd = picked;
      });
    }
  }

  Future<void> _selectPayDate(BuildContext context) async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: payDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9747FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != payDate && mounted) {
      setState(() {
        payDate = picked;
      });
    }
  }

  void _showPayrollTypeBottomSheet(BuildContext context) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Payroll Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            ...['Regular Payroll', 'Bonus Payment', 'Overtime Payment'].map(
              (type) => ListTile(
                title: Text(type),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      payrollType = type;
                    });
                  }
                  Navigator.pop(context);
                },
                trailing: payrollType == type ? Icon(Icons.check, color: Color(0xFF9747FF)) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Process automated batch payments for your employees with calculated deductions and taxes.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Payroll Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showPayrollTypeBottomSheet(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.work_outline, size: 18, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            payrollType,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay Period Start',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _selectPayPeriodStart(context),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                    SizedBox(width: 8),
                                    Text(
                                      '${payPeriodStart.day}/${payPeriodStart.month}/${payPeriodStart.year}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
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
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _selectPayPeriodEnd(context),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                    SizedBox(width: 8),
                                    Text(
                                      '${payPeriodEnd.day}/${payPeriodEnd.month}/${payPeriodEnd.year}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Pay Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectPayDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            '${payDate.day}/${payDate.month}/${payDate.year}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28),

                  Text(
                    'Employees to be paid',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${employeePayrollList.length} employees',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF9747FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF9747FF).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$selectedCount selected',
                          style: TextStyle(
                            color: Color(0xFF9747FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  if (isLoadingEmployees)
                    const PayrollEmployeesSkeleton()
                  else if (employeeLoadError != null)
                    Container(
                      padding: EdgeInsets.all(16),
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
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Failed to load employees',
                                  style: TextStyle(
                                    color: Colors.red[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            employeeLoadError!,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadEmployees,
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9747FF)),
                            child: Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  else if (employeePayrollList.isEmpty)
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No employees found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check console logs for debugging info. Add employees to your team to process payroll.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEmployees,
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9747FF)),
                            child: Text('Retry Loading', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  else
                    ...employeePayrollList.map((employeePayroll) => employeeCard(employeePayroll)),

                  SizedBox(height: 24),

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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9747FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

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
                                'Processing payroll will create payroll entries and payslips for selected employees.',
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

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
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
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedCount > 0 ? () => _processPayroll() : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Process Payroll',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedCount > 0 ? () => _processPayrollNow() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9747FF),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Send Payroll Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Process Payroll: Creates entries and payslips\nSend Payroll Now: Immediately processes payments and creates payslips',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget employeeCard(EmployeePayrollInfo employeePayroll) {
    final employee = employeePayroll.employee;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: employeePayroll.isSelected ? Color(0xFF9747FF).withValues(alpha: 0.5) : Colors.grey[200]!,
          width: employeePayroll.isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: employeePayroll.isSelected ? Color(0xFF9747FF).withValues(alpha: 0.1) : Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: employeePayroll.isSelected,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  employeePayroll.isSelected = value ?? false;
                });
              }
            },
            activeColor: Color(0xFF9747FF),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${employee.department ?? 'IT Department'} • ${employee.position ?? employee.role}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  employee.email,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Amount: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: employeePayroll.salaryController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '\$ ',
                          suffixText: ' USD',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 14),
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeePayrollInfo {
  final domain_employee.Employee employee;
  bool isSelected;
  late TextEditingController salaryController;

  EmployeePayrollInfo({
    required this.employee,
    this.isSelected = false,
  }) {
    final currentSalary = employee.payrollInfo?.salaryAmount ?? 0.0;
    salaryController = TextEditingController(
      text: currentSalary > 0 ? currentSalary.toStringAsFixed(0) : '0'
    );
  }

  void dispose() {
    salaryController.dispose();
  }
}

class _PayrollLoadingDialog extends StatefulWidget {
  final List<EmployeePayrollInfo> selectedEmployees;
  final DioClient dioClient;
  final PayslipRepository payslipRepository;

  const _PayrollLoadingDialog({
    required this.selectedEmployees,
    required this.dioClient,
    required this.payslipRepository,
  });

  @override
  _PayrollLoadingDialogState createState() => _PayrollLoadingDialogState();
}

class _PayrollLoadingDialogState extends State<_PayrollLoadingDialog> {
  bool showBackgroundOption = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showBackgroundOption = true;
        });
      }
    });
  }

  Future<void> _continuePayrollProcessingInBackground({
    required List<EmployeePayrollInfo> selectedEmployees,
    required DioClient dioClient,
    required PayslipRepository payslipRepository,
  }) async {
    try {

      final entryIds = <String>[];
      final employeeWalletMap = <String, String>{};

      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;

        try {

          final response = await dioClient.dio.post('/api/payroll/create/', data: {
            'employee_id': employee.userId,
            'employee_name': employee.displayName,
            'salary_amount': salaryAmount,
            'salary_currency': 'USD',
            'payment_frequency': 'MONTHLY',
            'start_date': DateTime.now().toIso8601String().split('T')[0],
          });

          if (response.statusCode == 200 && response.data['success'] == true) {
            final entryId = response.data['payroll_entry']['entry_id'];
            final employeeWallet = response.data['payroll_entry']['employee_wallet'];
            entryIds.add(entryId);
            employeeWalletMap[employee.userId] = employeeWallet;
          } else {
            debugPrint('Failed to create background payroll entry for ${employee.userId}: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error creating background payroll entry for ${employee.userId}: $e');
        }
      }

      if (entryIds.isEmpty) {
        return;
      }

      int processedEntries = 0;

      for (final entryId in entryIds) {
        try {

          final response = await dioClient.dio.post('/api/payroll/process/', data: {
            'entry_id': entryId,
          });

          if (response.statusCode == 200) {
            processedEntries++;
          } else {
            debugPrint('Failed to process background payroll entry $entryId: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error processing background payroll entry $entryId: $e');
        }
      }

      if (processedEntries > 0) {

        for (final employeePayroll in selectedEmployees) {
          final employee = employeePayroll.employee;
          final salaryText = employeePayroll.salaryController.text.trim();
          final salaryAmount = double.tryParse(salaryText) ?? 0.0;
          final employeeWallet = employeeWalletMap[employee.userId] ?? employee.payrollInfo?.employeeWallet;

          final payslipRequest = CreatePayslipRequest(
            employeeId: employee.userId,
            employeeName: employee.displayName,
            employeeEmail: employee.email,
            employeeWallet: employeeWallet,
            department: employee.department,
            position: employee.position,
            salaryAmount: salaryAmount,
            salaryCurrency: 'USD',
            cryptocurrency: 'ETH',
            payPeriodStart: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            payPeriodEnd: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            payDate: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            taxDeduction: 0.0,
            insuranceDeduction: 0.0,
            retirementDeduction: 0.0,
            otherDeductions: 0.0,
            overtimePay: 0.0,
            bonus: 0.0,
            allowances: 0.0,
            notes: 'Generated from mobile payroll processing - Background',
          );

          try {
            await payslipRepository.createPayslip(payslipRequest);
          } catch (e) {
            debugPrint('Error creating background payslip for ${employee.displayName}: $e');
          }
        }
      }


    } catch (e) {
      debugPrint('Critical error in background payroll processing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9747FF).withValues(alpha: 0.1),
                    Color(0xFF9747FF).withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Processing Payroll',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Sending payroll for ${widget.selectedEmployees.length} employees...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            AnimatedOpacity(
              opacity: showBackgroundOption ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final navContext = context;
                        final result = await showDialog<bool>(
                          context: navContext,
                          barrierDismissible: false,
                          builder: (context) => BackgroundProcessingDialog(),
                        );

                        if (result == true) {
                          if (!mounted) return;
                          final navigator = Navigator.of(navContext);
                          navigator.pop();
                          if (!mounted) return;
                          navigator.pop();

                          _continuePayrollProcessingInBackground(
                            selectedEmployees: widget.selectedEmployees,
                            dioClient: widget.dioClient,
                            payslipRepository: widget.payslipRepository,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF9747FF), width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.work_outline,
                        color: Color(0xFF9747FF),
                        size: 20,
                      ),
                      label: Text(
                        'Run in Background',
                        style: TextStyle(
                          color: Color(0xFF9747FF),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'You can continue using the app while payroll processes',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
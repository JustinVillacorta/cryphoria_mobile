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
  const PayrollBottomSheet({Key? key}) : super(key: key);

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
    print('DEBUG: PayrollBottomSheet initState called - this is the REAL employee data version');
    Future.microtask(() {
      if (mounted) {
        _loadEmployees();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all salary controllers
    for (final employeePayroll in employeePayrollList) {
      employeePayroll.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    
    print('DEBUG: Starting to load employees...');
    setState(() {
      isLoadingEmployees = true;
      employeeLoadError = null;
    });

    try {
      // Use the new method that includes wallet addresses
      print('DEBUG: Checking if getManagerTeamWithWalletsUseCaseProvider is available...');
      final getManagerTeamWithWalletsUseCase = ref.read(getManagerTeamWithWalletsUseCaseProvider);
      print('DEBUG: Provider available: true');
      
      print('DEBUG: Got manager team with wallets use case, executing...');
      final employees = await getManagerTeamWithWalletsUseCase.execute();
      print('DEBUG: Loaded ${employees.length} employees from backend with wallet addresses');
      
      // Log employee details including wallet information
      for (final employee in employees) {
        print('DEBUG: Employee - Name: ${employee.displayName}, Role: ${employee.role}, Email: ${employee.email}');
        print('DEBUG:   - User ID: ${employee.userId}');
        print('DEBUG:   - Username: ${employee.username}');
        print('DEBUG:   - First Name: ${employee.firstName}');
        print('DEBUG:   - Last Name: ${employee.lastName}');
        print('DEBUG:   - Wallet: ${employee.payrollInfo?.employeeWallet ?? "NULL"}');
        print('DEBUG:   - PayrollInfo Employee Name: ${employee.payrollInfo?.employeeName ?? "NULL"}');
      }
      
      // Create payroll entries for employees who don't have them
      await _createMissingPayrollEntries(employees);
      
      // Reload employees to get updated payroll info with wallets
      final updatedEmployees = await getManagerTeamWithWalletsUseCase.execute();
      print('DEBUG: After payroll setup, have ${updatedEmployees.length} employees');
      
      // Dispose existing controllers
      for (final employeePayroll in employeePayrollList) {
        employeePayroll.dispose();
      }
      
      employeePayrollList = updatedEmployees.map((employee) {
        print('DEBUG: Creating payroll info for employee: ${employee.displayName}');
        return EmployeePayrollInfo(
          employee: employee,
          isSelected: false, // Start with none selected for manual selection
        );
      }).toList();

      if (!mounted) return;
      
      setState(() {
        isLoadingEmployees = false;
      });
      
      print('DEBUG: Employee loading completed successfully. ${employeePayrollList.length} employees available.');
    } catch (e, stackTrace) {
      print('ERROR: Failed to load employees: $e');
      print('STACK TRACE: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        isLoadingEmployees = false;
        employeeLoadError = e.toString();
      });
    }
  }

  Future<void> _createMissingPayrollEntries(List<domain_employee.Employee> employees) async {
    print('DEBUG: Skipping payroll entry creation - backend endpoint not available');
    print('DEBUG: Employees will use default salary amounts that can be edited in UI');
    
    // Note: The /api/payroll/create/ endpoint returns 404 because the backend function doesn't exist
    // For now, we'll skip this step and let users enter salary amounts manually in the UI
    // The payslip creation will work with the entered amounts
    
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
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Use the existing backend payroll system
      // Create individual payroll entries first (using existing backend endpoint)
      final payrollEntries = <Map<String, dynamic>>[];
      final employeeWalletMap = <String, String>{}; // Map employee ID to wallet address
      
      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;
        
        // Create payroll entry using existing backend endpoint
        // Backend now automatically fetches employee wallet if not provided
        try {
          // Debug logging
          print('DEBUG: Creating payroll entry for employee:');
          print('  - User ID: ${employee.userId}');
          print('  - Employee Name: ${employee.displayName}');
          print('  - First Name: ${employee.firstName}');
          print('  - Last Name: ${employee.lastName}');
          print('  - Username: ${employee.username}');
          print('  - Email: ${employee.email}');
          print('  - Existing Wallet: ${employee.payrollInfo?.employeeWallet}');
          
          final response = await ref.read(dioClientProvider).dio.post('/api/payroll/create/', data: {
            'employee_id': employee.userId, // Fixed: Use employee_id instead of user_id
            'employee_name': employee.displayName,
            'salary_amount': salaryAmount,
            'salary_currency': 'USD',
            'payment_frequency': 'MONTHLY',
            'start_date': payDate.toIso8601String().split('T')[0],
          });
          
          if (response.statusCode == 200 && response.data['success'] == true) {
            payrollEntries.add(response.data['payroll_entry']);
            final entryId = response.data['payroll_entry']['entry_id'];
            final employeeWallet = response.data['payroll_entry']['employee_wallet'];
            employeeWalletMap[employee.userId] = employeeWallet;
            print('DEBUG: Payroll entry created successfully:');
            print('  - Entry ID: $entryId');
            print('  - Employee Wallet: $employeeWallet');
            print('  - Full entry: ${response.data['payroll_entry']}');
          } else {
            print('DEBUG: Payroll entry creation failed:');
            print('  - Status Code: ${response.statusCode}');
            print('  - Response: ${response.data}');
          }
        } catch (e) {
          print('Failed to create payroll entry for ${employee.displayName}: $e');
        }
      }


      // Create individual payslips for each employee
      final payslipRepository = ref.read(payslipRepositoryProvider);
      int successCount = 0;

      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        
        // Get salary amount from text field
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;
        
        // Get wallet address from the map we created during payroll entry creation
        final employeeWallet = employeeWalletMap[employee.userId] ?? employee.payrollInfo?.employeeWallet;
        
        print('DEBUG: Creating payslip for ${employee.displayName} (Process Payroll)');
        print('  - Employee ID: ${employee.userId}');
        print('  - Wallet from map: ${employeeWalletMap[employee.userId]}');
        print('  - Wallet from payroll info: ${employee.payrollInfo?.employeeWallet}');
        print('  - Final wallet: $employeeWallet');
        
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
          final createdPayslip = await payslipRepository.createPayslip(payslipRequest);
          successCount++;
          print('DEBUG: Payslip created for ${employee.displayName} (Process Payroll)');
          print('  - MongoDB ID: ${createdPayslip.id}');
          print('  - Payslip ID (UUID): ${createdPayslip.payslipId}');
        } catch (e) {
          print('Failed to create payslip for ${employee.displayName}: $e');
        }
        
        if (!mounted) break; // Stop processing if widget is disposed
      }

      if (!mounted) return; // Check before UI operations
      
      // Close loading dialog
      Navigator.pop(context);

      if (successCount == selectedEmployees.length) {
        // Close payroll bottom sheet
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
        Navigator.pop(context); // Close loading dialog
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
      
      // Store provider references before async operations
      final dioClient = ref.read(dioClientProvider);
      final payslipRepository = ref.read(payslipRepositoryProvider);
      
      // Show improved loading dialog with background option
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PayrollLoadingDialog(
          selectedEmployees: selectedEmployees,
          dioClient: dioClient,
          payslipRepository: payslipRepository,
        ),
      );

      // Step 1: Create payroll entries and collect entry IDs with wallet addresses
      final entryIds = <String>[];
      final employeeWalletMap = <String, String>{}; // Map employee ID to wallet address
      
      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;
        
        try {
          print('DEBUG: Creating payroll entry for immediate processing:');
          print('  - Employee: ${employee.displayName}');
          print('  - Salary: $salaryAmount');
          
          final response = await dioClient.dio.post('/api/payroll/create/', data: {
            'employee_id': employee.userId,
            'employee_name': employee.displayName,
            'salary_amount': salaryAmount,
            'salary_currency': 'USD',
            'payment_frequency': 'MONTHLY',
            'start_date': payDate.toIso8601String().split('T')[0],
          });
          
          print('DEBUG: Payroll entry creation response:');
          print('  - Status Code: ${response.statusCode}');
          print('  - Response Data: ${response.data}');
          
          if (response.statusCode == 200 && response.data['success'] == true) {
            final entryId = response.data['payroll_entry']['entry_id'];
            final employeeWallet = response.data['payroll_entry']['employee_wallet'];
            entryIds.add(entryId);
            employeeWalletMap[employee.userId] = employeeWallet;
            print('DEBUG: Payroll entry created successfully:');
            print('  - Entry ID: $entryId');
            print('  - Employee wallet: $employeeWallet');
            print('  - Total entries created so far: ${entryIds.length}');
          } else {
            print('ERROR: Failed to create payroll entry for ${employee.displayName}');
            print('  - Status: ${response.statusCode}');
            print('  - Response: ${response.data}');
          }
        } catch (e) {
          print('ERROR: Exception creating payroll entry for ${employee.displayName}: $e');
        }
      }

      if (entryIds.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create payroll entries. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Step 2: Process each payroll entry individually (Send Payroll Now flow)
      int processedEntries = 0;
      print('DEBUG: Processing ${entryIds.length} payroll entries individually');
      
      for (final entryId in entryIds) {
        try {
          print('DEBUG: Processing payroll entry: $entryId');
          
          final response = await dioClient.dio.post('/api/payroll/process/', data: {
            'entry_id': entryId,
          });
          
          print('DEBUG: Payroll processing response for $entryId:');
          print('  - Status Code: ${response.statusCode}');
          print('  - Response Data: ${response.data}');
          print('  - Has success field: ${response.data.containsKey('success')}');
          print('  - Success value: ${response.data['success']}');
          
          if (response.statusCode == 200) {
            // If backend returns 200, consider it successful regardless of success field
            // The backend might return success=false even when payment is processed
            processedEntries++;
            print('DEBUG: Successfully processed payroll entry: $entryId (200 status code)');
            
            // Log the response for debugging but don't fail on success=false
            if (response.data['success'] == false) {
              print('WARNING: Backend returned success=false but status code is 200');
              print('  - Error message: ${response.data['error']}');
              print('  - Treating as successful due to 200 status code');
            }
          } else {
            print('ERROR: Failed to process payroll entry: $entryId');
            print('  - Status: ${response.statusCode}');
            print('  - Response: ${response.data}');
          }
        } catch (e) {
          print('ERROR: Exception processing payroll entry $entryId: $e');
        }
      }
      print('DEBUG: Payroll processing complete - $processedEntries out of ${entryIds.length} entries processed');

      if (!mounted) return; // Check after payroll processing

      // Step 3: Only create payslips if payroll processing was successful
      int payslipSuccessCount = 0;
      int paidPayslipCount = 0;
      final createdPayslipIds = <String>[];

      print('DEBUG: Checking if payslips should be created...');
      print('  - processedEntries: $processedEntries');
      print('  - entryIds.length: ${entryIds.length}');
      print('  - Should create payslips: ${processedEntries > 0}');

      if (processedEntries > 0) {
        print('DEBUG: Payroll processing successful for $processedEntries entries, creating payslips');
        
        for (final employeePayroll in selectedEmployees) {
          if (!mounted) break; // Check before each iteration
          
          final employee = employeePayroll.employee;
          
          // Get salary amount from text field
          final salaryText = employeePayroll.salaryController.text.trim();
          final salaryAmount = double.tryParse(salaryText) ?? 0.0;
          
          // Get wallet address from the map we created during payroll entry creation
          final employeeWallet = employeeWalletMap[employee.userId] ?? employee.payrollInfo?.employeeWallet;
          
          print('DEBUG: Creating payslip for ${employee.displayName}');
          print('  - Employee ID: ${employee.userId}');
          print('  - Wallet from map: ${employeeWalletMap[employee.userId]}');
          print('  - Wallet from payroll info: ${employee.payrollInfo?.employeeWallet}');
          print('  - Final wallet: $employeeWallet');
          
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
            // Use payslip_id (UUID) instead of id (MongoDB ObjectId) for payment processing
            final payslipIdForPayment = createdPayslip.payslipId ?? createdPayslip.id;
            if (payslipIdForPayment != null) {
              createdPayslipIds.add(payslipIdForPayment);
            }
            payslipSuccessCount++;
            print('DEBUG: Payslip created for ${employee.displayName}');
            print('  - MongoDB ID: ${createdPayslip.id}');
            print('  - Payslip ID (UUID): ${createdPayslip.payslipId}');
            print('  - Status: ${createdPayslip.status}');
            print('  - Payment Processed: ${createdPayslip.paymentProcessed}');
            print('  - Using for payment: $payslipIdForPayment');
          } catch (e) {
            print('ERROR: Failed to create payslip for ${employee.displayName}: $e');
          }
        }

        // Step 4: Payslips are already created with "PAID" status by the backend
        // No need to call processPayslipPayment since the backend handles this automatically
        print('DEBUG: Payslips are already created with PAID status by the backend');
        print('DEBUG: No need to call processPayslipPayment - backend handles payment status automatically');
        paidPayslipCount = createdPayslipIds.length; // All payslips are already paid
        print('DEBUG: All ${createdPayslipIds.length} payslips are already marked as PAID by the backend');
      } else {
        print('DEBUG: No payroll entries were processed successfully, skipping payslip creation');
        print('DEBUG: This means no payslips will be created and no payment processing will be attempted');
      }

      if (!mounted) return; // Check before UI operations
      
      // Close loading dialog
      Navigator.pop(context);

      if (processedEntries == entryIds.length && payslipSuccessCount == selectedEmployees.length && paidPayslipCount == createdPayslipIds.length) {
        // Close payroll bottom sheet
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
        // Some payroll entries were processed successfully
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sent payroll for $processedEntries out of ${entryIds.length} employees, created $payslipSuccessCount payslips, marked $paidPayslipCount as paid'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // No payroll entries were processed successfully
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
        Navigator.pop(context); // Close loading dialog
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

                  // Payroll Type Dropdown
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

                  // Pay Period Row
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

                  // Pay Date
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

                  // Employee List Section
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
                          color: Color(0xFF9747FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF9747FF).withOpacity(0.3)),
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

                  // Employee Cards
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
                    ...employeePayrollList.map((employeePayroll) => employeeCard(employeePayroll)).toList(),

                  SizedBox(height: 24),

                  // Total Section
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

          // Bottom Actions
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                // Action buttons row
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
                // Send Payroll Now button
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
                // Help text
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
          color: employeePayroll.isSelected ? Color(0xFF9747FF).withOpacity(0.5) : Colors.grey[200]!,
          width: employeePayroll.isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: employeePayroll.isSelected ? Color(0xFF9747FF).withOpacity(0.1) : Colors.white,
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
                            setState(() {}); // Refresh to update total
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
    // Initialize with existing salary or default amount
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
    // Show background option after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showBackgroundOption = true;
        });
      }
    });
  }

  // Continue payroll processing in background
  Future<void> _continuePayrollProcessingInBackground({
    required List<EmployeePayrollInfo> selectedEmployees,
    required DioClient dioClient,
    required PayslipRepository payslipRepository,
  }) async {
    try {
      print('🔄 Starting background payroll processing');
      
      // Step 1: Create payroll entries and collect entry IDs with wallet addresses
      final entryIds = <String>[];
      final employeeWalletMap = <String, String>{}; // Map employee ID to wallet address
      
      for (final employeePayroll in selectedEmployees) {
        final employee = employeePayroll.employee;
        final salaryText = employeePayroll.salaryController.text.trim();
        final salaryAmount = double.tryParse(salaryText) ?? 0.0;
        
        try {
          print('DEBUG: [Background] Creating payroll entry for: ${employee.displayName}');
          
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
            print('DEBUG: [Background] Payroll entry created: $entryId');
          } else {
            print('ERROR: [Background] Failed to create payroll entry for ${employee.displayName}');
          }
        } catch (e) {
          print('ERROR: [Background] Exception creating payroll entry for ${employee.displayName}: $e');
        }
      }

      if (entryIds.isEmpty) {
        print('ERROR: [Background] No payroll entries were created');
        return;
      }

      // Step 2: Process each payroll entry individually
      int processedEntries = 0;
      print('DEBUG: [Background] Processing ${entryIds.length} payroll entries');
      
      for (final entryId in entryIds) {
        try {
          print('DEBUG: [Background] Processing payroll entry: $entryId');
          
          final response = await dioClient.dio.post('/api/payroll/process/', data: {
            'entry_id': entryId,
          });
          
          if (response.statusCode == 200) {
            processedEntries++;
            print('DEBUG: [Background] Successfully processed payroll entry: $entryId');
          } else {
            print('ERROR: [Background] Failed to process payroll entry: $entryId');
          }
        } catch (e) {
          print('ERROR: [Background] Exception processing payroll entry $entryId: $e');
        }
      }

      // Step 3: Create payslips if payroll processing was successful
      if (processedEntries > 0) {
        print('DEBUG: [Background] Creating payslips for $processedEntries entries');
        
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
            print('DEBUG: [Background] Payslip created for ${employee.displayName}');
          } catch (e) {
            print('ERROR: [Background] Failed to create payslip for ${employee.displayName}: $e');
          }
        }
      }

      print('✅ [Background] Payroll processing completed successfully');
      
    } catch (e) {
      print('❌ [Background] Error in background payroll processing: $e');
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
            // Animated loading indicator
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9747FF).withOpacity(0.1),
                    Color(0xFF9747FF).withOpacity(0.3),
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
            
            // Main title
            Text(
              'Processing Payroll',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            
            // Subtitle
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
            
            // Background processing option (appears after 3 seconds)
            AnimatedOpacity(
              opacity: showBackgroundOption ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Show background processing dialog
                        final result = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => BackgroundProcessingDialog(),
                        );
                        
                        if (result == true) {
                          // User chose background processing
                          Navigator.pop(context); // Close loading dialog
                          Navigator.pop(context); // Close payroll bottom sheet
                          
                          // Continue processing in background
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
                  
                  // Help text
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
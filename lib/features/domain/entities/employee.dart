// Employee entity aligned with backend user management API
class Employee {
  final String userId;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final PayrollInfo? payrollInfo;
  final String? firstName;
  final String? lastName;
  final String? department;
  final String? position;
  final String? profileImage;

  Employee({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    this.payrollInfo,
    this.firstName,
    this.lastName,
    this.department,
    this.position,
    this.profileImage,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty && 
        lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return username.isNotEmpty ? username : 'Unknown Employee';
  }

  String get employeeCode {
    if (userId.isEmpty) return 'EMP-UNKNOWN';
    final idPart = userId.length >= 8 ? userId.substring(0, 8) : userId;
    return 'EMP-${idPart.toUpperCase()}';
  }

  double get netPay => payrollInfo?.salaryAmount ?? 0.0;

  // Backward compatibility properties for existing UI
  String get name => displayName;
  String get id => userId;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? 'unknown',
      username: json['username'] as String? ?? 'unknown_user',
      email: json['email'] as String? ?? 'no-email@example.com',
      role: json['role'] as String? ?? 'Employee',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : (json['date_joined'] != null 
              ? DateTime.parse(json['date_joined'])
              : DateTime.now()),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'])
          : null,
      payrollInfo: json['payroll_info'] != null 
          ? PayrollInfo.fromJson(json['payroll_info'])
          : null,
      // Handle both individual first_name/last_name and combined full_name
      firstName: json['first_name'] as String? ?? 
                (json['full_name'] as String?)?.split(' ').first,
      lastName: json['last_name'] as String? ?? 
               (json['full_name'] as String?)?.split(' ').skip(1).join(' '),
      department: json['department'] as String?,
      position: json['position'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'role': role,
      'is_active': isActive,
      'date_joined': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'payroll_info': payrollInfo?.toJson(),
      'first_name': firstName,
      'last_name': lastName,
      'department': department,
      'position': position,
      'profile_image': profileImage,
    };
  }
}

// PayrollInfo entity aligned with backend payroll API
class PayrollInfo {
  final String? entryId;
  final String employeeName;
  final String? employeeWallet;
  final double salaryAmount;
  final String salaryCurrency;
  final String paymentFrequency;
  final DateTime startDate;
  final bool isActive;
  final String status;
  final double? usdEquivalent;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? processedAt;

  PayrollInfo({
    this.entryId,
    required this.employeeName,
    this.employeeWallet,
    required this.salaryAmount,
    required this.salaryCurrency,
    required this.paymentFrequency,
    required this.startDate,
    required this.isActive,
    required this.status,
    this.usdEquivalent,
    this.notes,
    this.createdAt,
    this.processedAt,
  });

  factory PayrollInfo.fromJson(Map<String, dynamic> json) {
    return PayrollInfo(
      entryId: json['entry_id'] as String?,
      employeeName: json['employee_name'] as String? ?? '',
      employeeWallet: json['employee_wallet'] as String?,
      salaryAmount: (json['salary_amount'] as num?)?.toDouble() ?? 0.0,
      salaryCurrency: json['salary_currency'] as String? ?? 'USDC',
      paymentFrequency: json['payment_frequency'] as String? ?? 'MONTHLY',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? 'SCHEDULED',
      usdEquivalent: (json['usd_equivalent'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'employee_name': employeeName,
      'employee_wallet': employeeWallet,
      'salary_amount': salaryAmount,
      'salary_currency': salaryCurrency,
      'payment_frequency': paymentFrequency,
      'start_date': startDate.toIso8601String(),
      'is_active': isActive,
      'status': status,
      'usd_equivalent': usdEquivalent,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}

// Payslip entity aligned with backend payslip API
class Payslip {
  final String payslipId;
  final String payslipNumber;
  final String employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String? employeeWallet;
  final String? department;
  final String? position;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double baseSalary;
  final String salaryCurrency;
  final String status;
  final double? overtimePay;
  final double? bonus;
  final double? allowances;
  final double? taxDeduction;
  final double? insuranceDeduction;
  final double? retirementDeduction;
  final double? otherDeductions;
  final double totalEarnings;
  final double totalDeductions;
  final double netPay;
  final DateTime createdAt;
  final DateTime? paidAt;

  Payslip({
    required this.payslipId,
    required this.payslipNumber,
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    this.employeeWallet,
    this.department,
    this.position,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.baseSalary,
    required this.salaryCurrency,
    required this.status,
    this.overtimePay,
    this.bonus,
    this.allowances,
    this.taxDeduction,
    this.insuranceDeduction,
    this.retirementDeduction,
    this.otherDeductions,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netPay,
    required this.createdAt,
    this.paidAt,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      payslipId: json['payslip_id'] as String? ?? '',
      payslipNumber: json['payslip_number'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? '',
      employeeEmail: json['employee_email'] as String?,
      employeeWallet: json['employee_wallet'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      payPeriodStart: DateTime.parse(json['pay_period_start']),
      payPeriodEnd: DateTime.parse(json['pay_period_end']),
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0.0,
      salaryCurrency: json['salary_currency'] as String? ?? 'USDC',
      status: json['status'] as String? ?? 'GENERATED',
      overtimePay: (json['overtime_pay'] as num?)?.toDouble(),
      bonus: (json['bonus'] as num?)?.toDouble(),
      allowances: (json['allowances'] as num?)?.toDouble(),
      taxDeduction: (json['tax_deduction'] as num?)?.toDouble(),
      insuranceDeduction: (json['insurance_deduction'] as num?)?.toDouble(),
      retirementDeduction: (json['retirement_deduction'] as num?)?.toDouble(),
      otherDeductions: (json['other_deductions'] as num?)?.toDouble(),
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      netPay: (json['net_pay'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payslip_id': payslipId,
      'payslip_number': payslipNumber,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'employee_wallet': employeeWallet,
      'department': department,
      'position': position,
      'pay_period_start': payPeriodStart.toIso8601String(),
      'pay_period_end': payPeriodEnd.toIso8601String(),
      'base_salary': baseSalary,
      'salary_currency': salaryCurrency,
      'status': status,
      'overtime_pay': overtimePay,
      'bonus': bonus,
      'allowances': allowances,
      'tax_deduction': taxDeduction,
      'insurance_deduction': insuranceDeduction,
      'retirement_deduction': retirementDeduction,
      'other_deductions': otherDeductions,
      'total_earnings': totalEarnings,
      'total_deductions': totalDeductions,
      'net_pay': netPay,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}

// Request models for API calls
class EmployeeRegistrationRequest {
  final String username;
  final String email;
  final String password;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? department;
  final String? position;

  EmployeeRegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.firstName,
    this.lastName,
    this.department,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'department': department,
      'position': position,
    };
  }
}

class PayrollCreateRequest {
  final String employeeId;
  final String employeeName;
  final double salaryAmount;
  final String salaryCurrency;
  final String paymentFrequency;
  final DateTime startDate;

  PayrollCreateRequest({
    required this.employeeId,
    required this.employeeName,
    required this.salaryAmount,
    required this.salaryCurrency,
    required this.paymentFrequency,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'salary_amount': salaryAmount,
      'salary_currency': salaryCurrency,
      'payment_frequency': paymentFrequency,
      'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
    };
  }
}

class PayslipCreateRequest {
  final String employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String? employeeWallet;
  final String? department;
  final String? position;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double salaryAmount;
  final String salaryCurrency;
  final double? overtimePay;
  final double? bonus;
  final double? allowances;
  final double? taxDeduction;
  final double? insuranceDeduction;
  final double? retirementDeduction;
  final double? otherDeductions;

  PayslipCreateRequest({
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    this.employeeWallet,
    this.department,
    this.position,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.salaryAmount,
    required this.salaryCurrency,
    this.overtimePay,
    this.bonus,
    this.allowances,
    this.taxDeduction,
    this.insuranceDeduction,
    this.retirementDeduction,
    this.otherDeductions,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'employee_wallet': employeeWallet,
      'department': department,
      'position': position,
      'pay_period_start': payPeriodStart.toIso8601String().split('T')[0],
      'pay_period_end': payPeriodEnd.toIso8601String().split('T')[0],
      'salary_amount': salaryAmount,
      'salary_currency': salaryCurrency,
      'overtime_pay': overtimePay,
      'bonus': bonus,
      'allowances': allowances,
      'tax_deduction': taxDeduction,
      'insurance_deduction': insuranceDeduction,
      'retirement_deduction': retirementDeduction,
      'other_deductions': otherDeductions,
    };
  }
}

// New request model for adding existing employees to team
class AddEmployeeToTeamRequest {
  final String email;
  final String? position;
  final String? department;
  final String? fullName;
  final String? phone;

  AddEmployeeToTeamRequest({
    required this.email,
    this.position,
    this.department,
    this.fullName,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'position': position,
      'department': department,
      'full_name': fullName,
      'phone': phone,
    };
  }
}

class RemoveEmployeeFromTeamRequest {
  final String email;

  RemoveEmployeeFromTeamRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class RemoveEmployeeFromTeamResponse {
  final bool success;
  final String message;

  RemoveEmployeeFromTeamResponse({
    required this.success,
    required this.message,
  });

  factory RemoveEmployeeFromTeamResponse.fromJson(Map<String, dynamic> json) {
    return RemoveEmployeeFromTeamResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

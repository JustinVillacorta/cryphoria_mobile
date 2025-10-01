// lib/features/domain/entities/payslip.dart

enum PayslipStatus {
  generated,
  paid,
  failed,
  pending,
  processing,
}

extension PayslipStatusExtension on PayslipStatus {
  String get displayName {
    switch (this) {
      case PayslipStatus.generated:
        return 'Generated';
      case PayslipStatus.paid:
        return 'Paid';
      case PayslipStatus.failed:
        return 'Failed';
      case PayslipStatus.pending:
        return 'Pending';
      case PayslipStatus.processing:
        return 'Processing';
    }
  }
  
  String get value {
    switch (this) {
      case PayslipStatus.generated:
        return 'GENERATED';
      case PayslipStatus.paid:
        return 'PAID';
      case PayslipStatus.failed:
        return 'FAILED';
      case PayslipStatus.pending:
        return 'PENDING';
      case PayslipStatus.processing:
        return 'PROCESSING';
    }
  }
}

class Payslip {
  final String payslipId;
  final String payslipNumber;
  final String userId;
  final String employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String? employeeWallet;
  final String department;
  final String position;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime payDate;
  final double baseSalary;
  final String salaryCurrency;
  final double overtimePay;
  final double bonus;
  final double allowances;
  final double totalEarnings;
  final double taxDeduction;
  final double insuranceDeduction;
  final double retirementDeduction;
  final double otherDeductions;
  final double totalDeductions;
  final double finalNetPay;
  final String cryptocurrency;
  final double cryptoAmount;
  final double usdEquivalent;
  final PayslipStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime issuedAt;
  final bool paymentProcessed;
  final bool pdfGenerated;

  const Payslip({
    required this.payslipId,
    required this.payslipNumber,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    this.employeeWallet,
    required this.department,
    required this.position,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.payDate,
    required this.baseSalary,
    required this.salaryCurrency,
    required this.overtimePay,
    required this.bonus,
    required this.allowances,
    required this.totalEarnings,
    required this.taxDeduction,
    required this.insuranceDeduction,
    required this.retirementDeduction,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.finalNetPay,
    required this.cryptocurrency,
    required this.cryptoAmount,
    required this.usdEquivalent,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.issuedAt,
    required this.paymentProcessed,
    required this.pdfGenerated,
  });

  Payslip copyWith({
    String? payslipId,
    String? payslipNumber,
    String? userId,
    String? employeeId,
    String? employeeName,
    String? employeeEmail,
    String? employeeWallet,
    String? department,
    String? position,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    DateTime? payDate,
    double? baseSalary,
    String? salaryCurrency,
    double? overtimePay,
    double? bonus,
    double? allowances,
    double? totalEarnings,
    double? taxDeduction,
    double? insuranceDeduction,
    double? retirementDeduction,
    double? otherDeductions,
    double? totalDeductions,
    double? finalNetPay,
    String? cryptocurrency,
    double? cryptoAmount,
    double? usdEquivalent,
    PayslipStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? issuedAt,
    bool? paymentProcessed,
    bool? pdfGenerated,
  }) {
    return Payslip(
      payslipId: payslipId ?? this.payslipId,
      payslipNumber: payslipNumber ?? this.payslipNumber,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeWallet: employeeWallet ?? this.employeeWallet,
      department: department ?? this.department,
      position: position ?? this.position,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      payDate: payDate ?? this.payDate,
      baseSalary: baseSalary ?? this.baseSalary,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      overtimePay: overtimePay ?? this.overtimePay,
      bonus: bonus ?? this.bonus,
      allowances: allowances ?? this.allowances,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      taxDeduction: taxDeduction ?? this.taxDeduction,
      insuranceDeduction: insuranceDeduction ?? this.insuranceDeduction,
      retirementDeduction: retirementDeduction ?? this.retirementDeduction,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      finalNetPay: finalNetPay ?? this.finalNetPay,
      cryptocurrency: cryptocurrency ?? this.cryptocurrency,
      cryptoAmount: cryptoAmount ?? this.cryptoAmount,
      usdEquivalent: usdEquivalent ?? this.usdEquivalent,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      issuedAt: issuedAt ?? this.issuedAt,
      paymentProcessed: paymentProcessed ?? this.paymentProcessed,
      pdfGenerated: pdfGenerated ?? this.pdfGenerated,
    );
  }
}
// lib/features/data/models/payslip_model.dart

import '../../domain/entities/payslip.dart';

class PayslipModel extends Payslip {
  const PayslipModel({
    required super.payslipId,
    required super.payslipNumber,
    required super.userId,
    required super.employeeId,
    required super.employeeName,
    super.employeeEmail,
    super.employeeWallet,
    required super.department,
    required super.position,
    required super.payPeriodStart,
    required super.payPeriodEnd,
    required super.payDate,
    required super.baseSalary,
    required super.salaryCurrency,
    required super.overtimePay,
    required super.bonus,
    required super.allowances,
    required super.totalEarnings,
    required super.taxDeduction,
    required super.insuranceDeduction,
    required super.retirementDeduction,
    required super.otherDeductions,
    required super.totalDeductions,
    required super.finalNetPay,
    required super.cryptocurrency,
    required super.cryptoAmount,
    required super.usdEquivalent,
    required super.status,
    required super.notes,
    required super.createdAt,
    required super.issuedAt,
    required super.paymentProcessed,
    required super.pdfGenerated,
  });

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      payslipId: json['payslip_id'] ?? '',
      payslipNumber: json['payslip_number'] ?? '',
      userId: json['user_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      employeeName: json['employee_name'] ?? '',
      employeeEmail: json['employee_email'],
      employeeWallet: json['employee_wallet'],
      department: json['department'] ?? 'General',
      position: json['position'] ?? 'Employee',
      payPeriodStart: DateTime.parse(json['pay_period_start']),
      payPeriodEnd: DateTime.parse(json['pay_period_end']),
      payDate: DateTime.parse(json['pay_date']),
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      salaryCurrency: json['salary_currency'] ?? 'USD',
      overtimePay: (json['overtime_pay'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      allowances: (json['allowances'] ?? 0).toDouble(),
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      taxDeduction: (json['tax_deduction'] ?? 0).toDouble(),
      insuranceDeduction: (json['insurance_deduction'] ?? 0).toDouble(),
      retirementDeduction: (json['retirement_deduction'] ?? 0).toDouble(),
      otherDeductions: (json['other_deductions'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      finalNetPay: (json['final_net_pay'] ?? 0).toDouble(),
      cryptocurrency: json['cryptocurrency'] ?? 'ETH',
      cryptoAmount: (json['crypto_amount'] ?? 0).toDouble(),
      usdEquivalent: (json['usd_equivalent'] ?? 0).toDouble(),
      status: _parsePayslipStatus(json['status']),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      issuedAt: DateTime.parse(json['issued_at'] ?? DateTime.now().toIso8601String()),
      paymentProcessed: json['payment_processed'] ?? false,
      pdfGenerated: json['pdf_generated'] ?? false,
    );
  }

  static PayslipStatus _parsePayslipStatus(String? statusString) {
    switch (statusString?.toUpperCase()) {
      case 'GENERATED':
        return PayslipStatus.generated;
      case 'PAID':
        return PayslipStatus.paid;
      case 'FAILED':
        return PayslipStatus.failed;
      case 'PENDING':
        return PayslipStatus.pending;
      case 'PROCESSING':
        return PayslipStatus.processing;
      default:
        return PayslipStatus.generated;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'payslip_id': payslipId,
      'payslip_number': payslipNumber,
      'user_id': userId,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'employee_wallet': employeeWallet,
      'department': department,
      'position': position,
      'pay_period_start': payPeriodStart.toIso8601String(),
      'pay_period_end': payPeriodEnd.toIso8601String(),
      'pay_date': payDate.toIso8601String(),
      'base_salary': baseSalary,
      'salary_currency': salaryCurrency,
      'overtime_pay': overtimePay,
      'bonus': bonus,
      'allowances': allowances,
      'total_earnings': totalEarnings,
      'tax_deduction': taxDeduction,
      'insurance_deduction': insuranceDeduction,
      'retirement_deduction': retirementDeduction,
      'other_deductions': otherDeductions,
      'total_deductions': totalDeductions,
      'final_net_pay': finalNetPay,
      'cryptocurrency': cryptocurrency,
      'crypto_amount': cryptoAmount,
      'usd_equivalent': usdEquivalent,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'issued_at': issuedAt.toIso8601String(),
      'payment_processed': paymentProcessed,
      'pdf_generated': pdfGenerated,
    };
  }
}
import 'package:flutter/material.dart';

enum PayslipStatus {
  draft('DRAFT'),
  generated('GENERATED'),
  sent('SENT'),
  paid('PAID'),
  cancelled('CANCELLED'),
  processing('PROCESSING'),
  failed('FAILED'),
  pending('PENDING');

  const PayslipStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PayslipStatus.draft:
        return 'Draft';
      case PayslipStatus.generated:
        return 'Generated';
      case PayslipStatus.sent:
        return 'Sent';
      case PayslipStatus.paid:
        return 'Paid';
      case PayslipStatus.cancelled:
        return 'Cancelled';
      case PayslipStatus.processing:
        return 'Processing';
      case PayslipStatus.failed:
        return 'Failed';
      case PayslipStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case PayslipStatus.draft:
        return Colors.orange;
      case PayslipStatus.generated:
        return Colors.blue;
      case PayslipStatus.sent:
        return Colors.purple;
      case PayslipStatus.paid:
        return Colors.green;
      case PayslipStatus.cancelled:
        return Colors.red;
      case PayslipStatus.processing:
        return Colors.amber;
      case PayslipStatus.failed:
        return Colors.red;
      case PayslipStatus.pending:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case PayslipStatus.draft:
        return Icons.edit;
      case PayslipStatus.generated:
        return Icons.description;
      case PayslipStatus.sent:
        return Icons.send;
      case PayslipStatus.paid:
        return Icons.check_circle;
      case PayslipStatus.cancelled:
        return Icons.cancel;
      case PayslipStatus.processing:
        return Icons.hourglass_empty;
      case PayslipStatus.failed:
        return Icons.error;
      case PayslipStatus.pending:
        return Icons.schedule;
    }
  }

  static PayslipStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return PayslipStatus.draft;
      case 'GENERATED':
        return PayslipStatus.generated;
      case 'SENT':
        return PayslipStatus.sent;
      case 'PAID':
        return PayslipStatus.paid;
      case 'CANCELLED':
        return PayslipStatus.cancelled;
      case 'PROCESSING':
        return PayslipStatus.processing;
      case 'FAILED':
        return PayslipStatus.failed;
      case 'PENDING':
        return PayslipStatus.pending;
      default:
        return PayslipStatus.draft;
    }
  }
}

class Payslip {
  final String? id;
  final String? payslipId;
  final String? payslipNumber;
  final String? userId;
  final String? employeeId;
  final String? employeeName;
  final String? employeeEmail;
  final String? employeeWallet;
  final String? department;
  final String? position;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime payDate;
  final double baseSalary;
  final String? salaryCurrency;
  final double overtimePay;
  final double bonus;
  final double allowances;
  final double totalEarnings;
  final double taxDeduction;
  final double insuranceDeduction;
  final double retirementDeduction;
  final double otherDeductions;
  final double totalDeductions;
  final double grossAmount;
  final double netAmount;
  final double finalNetPay;
  final String? cryptocurrency;
  final double cryptoAmount;
  final double usdEquivalent;
  final String? status;
  final String? notes;
  final DateTime createdAt;
  final DateTime issuedAt;
  final bool? paymentProcessed;
  final bool? pdfGenerated;
  final Map<String, dynamic>? taxBreakdown;
  final Map<String, dynamic>? taxDeductions;
  final double totalTaxDeducted;
  final Map<String, dynamic>? taxRatesApplied;
  final String? taxConfigSource;
  final DateTime? pdfGeneratedAt;
  final DateTime? sentAt;

  const Payslip({
    this.id,
    this.payslipId,
    this.payslipNumber,
    this.userId,
    this.employeeId,
    this.employeeName,
    this.employeeEmail,
    this.employeeWallet,
    this.department,
    this.position,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.payDate,
    required this.baseSalary,
    this.salaryCurrency,
    required this.overtimePay,
    required this.bonus,
    required this.allowances,
    required this.totalEarnings,
    required this.taxDeduction,
    required this.insuranceDeduction,
    required this.retirementDeduction,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.grossAmount,
    required this.netAmount,
    required this.finalNetPay,
    this.cryptocurrency,
    required this.cryptoAmount,
    required this.usdEquivalent,
    this.status,
    this.notes,
    required this.createdAt,
    required this.issuedAt,
    this.paymentProcessed,
    this.pdfGenerated,
    this.taxBreakdown,
    this.taxDeductions,
    required this.totalTaxDeducted,
    this.taxRatesApplied,
    this.taxConfigSource,
    this.pdfGeneratedAt,
    this.sentAt,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['_id'] as String?,
      payslipId: json['payslip_id'] as String?,
      payslipNumber: json['payslip_number'] as String?,
      userId: json['user_id'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      employeeEmail: json['employee_email'] as String?,
      employeeWallet: json['employee_wallet'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      payPeriodStart: DateTime.parse(json['pay_period_start'] as String? ?? DateTime.now().toIso8601String()),
      payPeriodEnd: DateTime.parse(json['pay_period_end'] as String? ?? DateTime.now().toIso8601String()),
      payDate: DateTime.parse(json['pay_date'] as String? ?? DateTime.now().toIso8601String()),
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0.0,
      salaryCurrency: json['salary_currency'] as String?,
      overtimePay: (json['overtime_pay'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      allowances: (json['allowances'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      taxDeduction: (json['tax_deduction'] as num?)?.toDouble() ?? 0.0,
      insuranceDeduction: (json['insurance_deduction'] as num?)?.toDouble() ?? 0.0,
      retirementDeduction: (json['retirement_deduction'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['other_deductions'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      finalNetPay: (json['final_net_pay'] as num?)?.toDouble() ?? 0.0,
      cryptocurrency: json['cryptocurrency'] as String?,
      cryptoAmount: (json['crypto_amount'] as num?)?.toDouble() ?? 0.0,
      usdEquivalent: (json['usd_equivalent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      issuedAt: DateTime.parse(json['issued_at'] as String? ?? DateTime.now().toIso8601String()),
      paymentProcessed: json['payment_processed'] as bool?,
      pdfGenerated: json['pdf_generated'] as bool?,
      taxBreakdown: json['tax_breakdown'] as Map<String, dynamic>?,
      taxDeductions: json['tax_deductions'] as Map<String, dynamic>?,
      totalTaxDeducted: (json['total_tax_deducted'] as num?)?.toDouble() ?? 0.0,
      taxRatesApplied: json['tax_rates_applied'] as Map<String, dynamic>?,
      taxConfigSource: json['tax_config_source'] as String?,
      pdfGeneratedAt: json['pdf_generated_at'] != null 
          ? DateTime.parse(json['pdf_generated_at'] as String) 
          : null,
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at'] as String) 
          : null,
    );
  }

  PayslipStatus get statusEnum => PayslipStatus.fromString(status ?? 'DRAFT');

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
      'gross_amount': grossAmount,
      'net_amount': netAmount,
      'final_net_pay': finalNetPay,
      'cryptocurrency': cryptocurrency,
      'crypto_amount': cryptoAmount,
      'usd_equivalent': usdEquivalent,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'issued_at': issuedAt.toIso8601String(),
      'payment_processed': paymentProcessed,
      'pdf_generated': pdfGenerated,
      'tax_breakdown': taxBreakdown,
      'tax_deductions': taxDeductions,
      'total_tax_deducted': totalTaxDeducted,
      'tax_rates_applied': taxRatesApplied,
      'tax_config_source': taxConfigSource,
      'pdf_generated_at': pdfGeneratedAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
  }
}

class PayslipsResponse {
  final bool success;
  final List<Payslip> payslips;
  final int totalCount;

  const PayslipsResponse({
    required this.success,
    required this.payslips,
    required this.totalCount,
  });

  factory PayslipsResponse.fromJson(Map<String, dynamic> json) {
    return PayslipsResponse(
      success: json['success'] as bool,
      payslips: (json['payslips'] as List<dynamic>)
          .map((e) => Payslip.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payslips': payslips.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}
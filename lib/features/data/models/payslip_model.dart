import '../../domain/entities/payslip.dart';

class PayslipModel extends Payslip {
  const PayslipModel({
    super.id,
    super.payslipId,
    super.payslipNumber,
    super.userId,
    super.employeeId,
    super.employeeName,
    super.employeeEmail,
    super.employeeWallet,
    super.department,
    super.position,
    required super.payPeriodStart,
    required super.payPeriodEnd,
    required super.payDate,
    required super.baseSalary,
    super.salaryCurrency,
    required super.overtimePay,
    required super.bonus,
    required super.allowances,
    required super.totalEarnings,
    required super.taxDeduction,
    required super.insuranceDeduction,
    required super.retirementDeduction,
    required super.otherDeductions,
    required super.totalDeductions,
    required super.grossAmount,
    required super.netAmount,
    required super.finalNetPay,
    super.cryptocurrency,
    required super.cryptoAmount,
    required super.usdEquivalent,
    super.status,
    super.notes,
    required super.createdAt,
    required super.issuedAt,
    super.paymentProcessed,
    super.pdfGenerated,
    super.taxBreakdown,
    super.taxDeductions,
    required super.totalTaxDeducted,
    super.taxRatesApplied,
    super.taxConfigSource,
    super.pdfGeneratedAt,
    super.sentAt,
  });

      factory PayslipModel.fromJson(Map<String, dynamic> json) {

        try {

          if (json['employee_wallet'] == null) {
          }
          if (json['payment_processed'] == null) {
          }
          if (json['pdf_generated'] == null) {
          }
          if (json['pay_period_start'] == null) {
          }
          if (json['pay_period_end'] == null) {
          }
          if (json['pay_date'] == null) {
          }
          if (json['created_at'] == null) {
          }
          if (json['issued_at'] == null) {
          }
          if (json['base_salary'] == null) {
          }
          if (json['overtime_pay'] == null) {
          }
          if (json['bonus'] == null) {
          }
          if (json['allowances'] == null) {
          }
          if (json['total_earnings'] == null) {
          }
          if (json['final_net_pay'] == null) {
          }

          final payslip = PayslipModel(
            id: json['_id'] as String? ?? 'unknown_id',
            payslipId: json['payslip_id'] as String? ?? 'unknown_payslip_id',
            payslipNumber: json['payslip_number'] as String? ?? 'unknown_number',
            userId: json['user_id'] as String? ?? 'unknown_user',
            employeeId: json['employee_id'] as String? ?? 'unknown_employee',
            employeeName: json['employee_name'] as String? ?? 'Unknown Employee',
            employeeEmail: json['employee_email'] as String? ?? 'No Email',
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

          return payslip;
        } catch (e) {
          rethrow;
        }
      }

  @override
  @override
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
    };
  }

  Payslip toEntity() {
    return Payslip(
      id: id,
      payslipId: payslipId,
      payslipNumber: payslipNumber,
      userId: userId,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      employeeWallet: employeeWallet,
      department: department,
      position: position,
      payPeriodStart: payPeriodStart,
      payPeriodEnd: payPeriodEnd,
      payDate: payDate,
      baseSalary: baseSalary,
      salaryCurrency: salaryCurrency,
      overtimePay: overtimePay,
      bonus: bonus,
      allowances: allowances,
      totalEarnings: totalEarnings,
      taxDeduction: taxDeduction,
      insuranceDeduction: insuranceDeduction,
      retirementDeduction: retirementDeduction,
      otherDeductions: otherDeductions,
      totalDeductions: totalDeductions,
      grossAmount: grossAmount,
      netAmount: netAmount,
      finalNetPay: finalNetPay,
      cryptocurrency: cryptocurrency,
      cryptoAmount: cryptoAmount,
      usdEquivalent: usdEquivalent,
      status: status,
      notes: notes,
      createdAt: createdAt,
      issuedAt: issuedAt,
      paymentProcessed: paymentProcessed,
      pdfGenerated: pdfGenerated,
      taxBreakdown: taxBreakdown,
      taxDeductions: taxDeductions,
      totalTaxDeducted: totalTaxDeducted,
      taxRatesApplied: taxRatesApplied,
      taxConfigSource: taxConfigSource,
      pdfGeneratedAt: pdfGeneratedAt,
      sentAt: sentAt,
    );
  }
}

class PayslipsResponseModel extends PayslipsResponse {
  const PayslipsResponseModel({
    required super.success,
    required super.payslips,
    required super.totalCount,
  });

      factory PayslipsResponseModel.fromJson(Map<String, dynamic> json) {

        try {

          final response = PayslipsResponseModel(
            success: json['success'] as bool,
            payslips: (json['payslips'] as List<dynamic>)
                .map((e) => PayslipModel.fromJson(e as Map<String, dynamic>))
                .toList(),
            totalCount: json['total_count'] as int? ?? 0,
          );

          return response;
        } catch (e) {
          rethrow;
        }
      }

  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payslips': payslips.map((e) => (e as PayslipModel).toJson()).toList(),
    };
  }

  PayslipsResponse toEntity() {
    return PayslipsResponse(
      success: success,
      payslips: payslips.map((e) => (e as PayslipModel).toEntity()).toList(),
      totalCount: totalCount,
    );
  }
}

import '../../domain/entities/payroll_entry.dart';

class PayrollEntryModel extends PayrollEntry {
  const PayrollEntryModel({
    super.id,
    super.entryId,
    super.userId,
    super.employeeName,
    super.employeeWallet,
    required super.salaryAmount,
    super.salaryCurrency,
    super.paymentFrequency,
    required super.amount,
    super.cryptocurrency,
    required super.usdEquivalent,
    required super.paymentDate,
    required super.startDate,
    required super.isActive,
    super.status,
    super.notes,
    required super.createdAt,
    super.processedAt,
    super.gasFee,
    super.transactionHash,
    super.payslipId,
    required super.payslipSent,
    super.payslipSentAt,
    super.errorMessage,
  });

  factory PayrollEntryModel.fromJson(Map<String, dynamic> json) {
    return PayrollEntryModel(
      id: json['_id'] as String?,
      entryId: json['entry_id'] as String?,
      userId: json['user_id'] as String?,
      employeeName: json['employee_name'] as String?,
      employeeWallet: json['employee_wallet'] as String?,
      salaryAmount: (json['salary_amount'] as num?)?.toDouble() ?? 0.0,
      salaryCurrency: json['salary_currency'] as String?,
      paymentFrequency: json['payment_frequency'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      cryptocurrency: json['cryptocurrency'] as String?,
      usdEquivalent: (json['usd_equivalent'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(json['payment_date'] as String? ?? DateTime.now().toIso8601String()),
      startDate: DateTime.parse(json['start_date'] as String? ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'] as String) 
          : null,
      gasFee: (json['gas_fee'] as num?)?.toDouble(),
      transactionHash: json['transaction_hash'] as String?,
      payslipId: json['payslip_id'] as String?,
      payslipSent: json['payslip_sent'] as bool? ?? false,
      payslipSentAt: json['payslip_sent_at'] != null 
          ? DateTime.parse(json['payslip_sent_at'] as String) 
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'entry_id': entryId,
      'user_id': userId,
      'employee_name': employeeName,
      'employee_wallet': employeeWallet,
      'salary_amount': salaryAmount,
      'salary_currency': salaryCurrency,
      'payment_frequency': paymentFrequency,
      'amount': amount,
      'cryptocurrency': cryptocurrency,
      'usd_equivalent': usdEquivalent,
      'payment_date': paymentDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'is_active': isActive,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'gas_fee': gasFee,
      'transaction_hash': transactionHash,
      'payslip_id': payslipId,
      'payslip_sent': payslipSent,
      'payslip_sent_at': payslipSentAt?.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  PayrollEntry toEntity() {
    return PayrollEntry(
      id: id,
      entryId: entryId,
      userId: userId,
      employeeName: employeeName,
      employeeWallet: employeeWallet,
      salaryAmount: salaryAmount,
      salaryCurrency: salaryCurrency,
      paymentFrequency: paymentFrequency,
      amount: amount,
      cryptocurrency: cryptocurrency,
      usdEquivalent: usdEquivalent,
      paymentDate: paymentDate,
      startDate: startDate,
      isActive: isActive,
      status: status,
      notes: notes,
      createdAt: createdAt,
      processedAt: processedAt,
      gasFee: gasFee,
      transactionHash: transactionHash,
      payslipId: payslipId,
      payslipSent: payslipSent,
      payslipSentAt: payslipSentAt,
      errorMessage: errorMessage,
    );
  }
}
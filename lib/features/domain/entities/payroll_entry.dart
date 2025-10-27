
class PayrollEntry {
  final String? id;
  final String? entryId;
  final String? userId;
  final String? employeeName;
  final String? employeeWallet;
  final double salaryAmount;
  final String? salaryCurrency;
  final String? paymentFrequency;
  final double amount;
  final String? cryptocurrency;
  final double usdEquivalent;
  final DateTime paymentDate;
  final DateTime startDate;
  final bool isActive;
  final String? status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? processedAt;
  final double? gasFee;
  final String? transactionHash;
  final String? payslipId;
  final bool payslipSent;
  final DateTime? payslipSentAt;
  final String? errorMessage;

  const PayrollEntry({
    this.id,
    this.entryId,
    this.userId,
    this.employeeName,
    this.employeeWallet,
    required this.salaryAmount,
    this.salaryCurrency,
    this.paymentFrequency,
    required this.amount,
    this.cryptocurrency,
    required this.usdEquivalent,
    required this.paymentDate,
    required this.startDate,
    required this.isActive,
    this.status,
    this.notes,
    required this.createdAt,
    this.processedAt,
    this.gasFee,
    this.transactionHash,
    this.payslipId,
    required this.payslipSent,
    this.payslipSentAt,
    this.errorMessage,
  });

  factory PayrollEntry.fromJson(Map<String, dynamic> json) {
    return PayrollEntry(
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
}
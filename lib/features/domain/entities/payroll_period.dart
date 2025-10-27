class PayrollPeriod {
  final String periodId;
  final String periodNumber;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime payDate;
  final PayrollPeriodStatus status;
  final double totalAmount;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? processedAt;
  final List<PayrollEntry> entries;
  final PayrollSummary? summary;

  const PayrollPeriod({
    required this.periodId,
    required this.periodNumber,
    required this.startDate,
    required this.endDate,
    required this.payDate,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.createdBy,
    required this.createdAt,
    this.processedAt,
    required this.entries,
    this.summary,
  });

  factory PayrollPeriod.fromJson(Map<String, dynamic> json) {
    return PayrollPeriod(
      periodId: json['period_id'] as String? ?? '',
      periodNumber: json['period_number'] as String? ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      payDate: json['pay_date'] != null 
          ? DateTime.parse(json['pay_date'])
          : DateTime.now(),
      status: PayrollPeriodStatus.fromString(json['status'] as String? ?? 'draft'),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'])
          : null,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => PayrollEntry.fromJson(e))
              .toList() ?? [],
      summary: json['summary'] != null 
          ? PayrollSummary.fromJson(json['summary'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_id': periodId,
      'period_number': periodNumber,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'pay_date': payDate.toIso8601String().split('T')[0],
      'status': status.value,
      'total_amount': totalAmount,
      'currency': currency,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'summary': summary?.toJson(),
    };
  }

  PayrollPeriod copyWith({
    String? periodId,
    String? periodNumber,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? payDate,
    PayrollPeriodStatus? status,
    double? totalAmount,
    String? currency,
    String? createdBy,
    DateTime? createdAt,
    DateTime? processedAt,
    List<PayrollEntry>? entries,
    PayrollSummary? summary,
  }) {
    return PayrollPeriod(
      periodId: periodId ?? this.periodId,
      periodNumber: periodNumber ?? this.periodNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      payDate: payDate ?? this.payDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      entries: entries ?? this.entries,
      summary: summary ?? this.summary,
    );
  }

  String get periodDescription {
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  int get totalEmployees => entries.length;

  double get totalPending => entries
      .where((e) => e.status == PayrollEntryStatus.pending)
      .fold(0.0, (sum, e) => sum + e.netAmount);

  double get totalPaid => entries
      .where((e) => e.status == PayrollEntryStatus.paid)
      .fold(0.0, (sum, e) => sum + e.netAmount);

  bool get canProcess => status == PayrollPeriodStatus.draft && entries.isNotEmpty;
  bool get canEdit => status == PayrollPeriodStatus.draft;
  bool get isCompleted => status == PayrollPeriodStatus.paid;
}

enum PayrollPeriodStatus {
  draft('draft'),
  processing('processing'),
  paid('paid'),
  cancelled('cancelled');

  const PayrollPeriodStatus(this.value);
  final String value;

  static PayrollPeriodStatus fromString(String value) {
    return PayrollPeriodStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PayrollPeriodStatus.draft,
    );
  }

  String get displayName {
    switch (this) {
      case PayrollPeriodStatus.draft:
        return 'Draft';
      case PayrollPeriodStatus.processing:
        return 'Processing';
      case PayrollPeriodStatus.paid:
        return 'Paid';
      case PayrollPeriodStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class PayrollEntry {
  final String entryId;
  final String employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String? employeeWallet;
  final String department;
  final String position;
  final double baseSalary;
  final double overtimeHours;
  final double overtimeRate;
  final double overtimeAmount;
  final double bonusAmount;
  final Map<String, double> allowances;
  final Map<String, double> deductions;
  final double grossSalary;
  final double totalDeductions;
  final double netAmount;
  final String currency;
  final PayrollEntryStatus status;
  final String? transactionHash;
  final DateTime? paidAt;

  const PayrollEntry({
    required this.entryId,
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    this.employeeWallet,
    required this.department,
    required this.position,
    required this.baseSalary,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.overtimeAmount,
    required this.bonusAmount,
    required this.allowances,
    required this.deductions,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netAmount,
    required this.currency,
    required this.status,
    this.transactionHash,
    this.paidAt,
  });

  factory PayrollEntry.fromJson(Map<String, dynamic> json) {
    return PayrollEntry(
      entryId: json['entry_id'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? '',
      employeeEmail: json['employee_email'] as String?,
      employeeWallet: json['employee_wallet'] as String?,
      department: json['department'] as String? ?? '',
      position: json['position'] as String? ?? '',
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0.0,
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      overtimeRate: (json['overtime_rate'] as num?)?.toDouble() ?? 0.0,
      overtimeAmount: (json['overtime_amount'] as num?)?.toDouble() ?? 0.0,
      bonusAmount: (json['bonus_amount'] as num?)?.toDouble() ?? 0.0,
      allowances: Map<String, double>.from(
        (json['allowances'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      deductions: Map<String, double>.from(
        (json['deductions'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      grossSalary: (json['gross_salary'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      status: PayrollEntryStatus.fromString(json['status'] as String? ?? 'pending'),
      transactionHash: json['transaction_hash'] as String?,
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'employee_wallet': employeeWallet,
      'department': department,
      'position': position,
      'base_salary': baseSalary,
      'overtime_hours': overtimeHours,
      'overtime_rate': overtimeRate,
      'overtime_amount': overtimeAmount,
      'bonus_amount': bonusAmount,
      'allowances': allowances,
      'deductions': deductions,
      'gross_salary': grossSalary,
      'total_deductions': totalDeductions,
      'net_amount': netAmount,
      'currency': currency,
      'status': status.value,
      'transaction_hash': transactionHash,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  double get totalAllowances => allowances.values.fold(0.0, (sum, amount) => sum + amount);
  double get totalDeductionsAmount => deductions.values.fold(0.0, (sum, amount) => sum + amount);
}

enum PayrollEntryStatus {
  pending('pending'),
  processing('processing'),
  paid('paid'),
  failed('failed');

  const PayrollEntryStatus(this.value);
  final String value;

  static PayrollEntryStatus fromString(String value) {
    return PayrollEntryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PayrollEntryStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case PayrollEntryStatus.pending:
        return 'Pending';
      case PayrollEntryStatus.processing:
        return 'Processing';
      case PayrollEntryStatus.paid:
        return 'Paid';
      case PayrollEntryStatus.failed:
        return 'Failed';
    }
  }
}

class PayrollSummary {
  final int totalEmployees;
  final double totalGrossSalary;
  final double totalAllowances;
  final double totalDeductions;
  final double totalNetAmount;
  final int pendingPayments;
  final int completedPayments;
  final int failedPayments;

  const PayrollSummary({
    required this.totalEmployees,
    required this.totalGrossSalary,
    required this.totalAllowances,
    required this.totalDeductions,
    required this.totalNetAmount,
    required this.pendingPayments,
    required this.completedPayments,
    required this.failedPayments,
  });

  factory PayrollSummary.fromJson(Map<String, dynamic> json) {
    return PayrollSummary(
      totalEmployees: json['total_employees'] as int? ?? 0,
      totalGrossSalary: (json['total_gross_salary'] as num?)?.toDouble() ?? 0.0,
      totalAllowances: (json['total_allowances'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      totalNetAmount: (json['total_net_amount'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: json['pending_payments'] as int? ?? 0,
      completedPayments: json['completed_payments'] as int? ?? 0,
      failedPayments: json['failed_payments'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_employees': totalEmployees,
      'total_gross_salary': totalGrossSalary,
      'total_allowances': totalAllowances,
      'total_deductions': totalDeductions,
      'total_net_amount': totalNetAmount,
      'pending_payments': pendingPayments,
      'completed_payments': completedPayments,
      'failed_payments': failedPayments,
    };
  }
}

class CreatePayrollPeriodRequest {
  final String periodNumber;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime payDate;
  final String currency;
  final List<String> employeeIds;

  const CreatePayrollPeriodRequest({
    required this.periodNumber,
    required this.startDate,
    required this.endDate,
    required this.payDate,
    required this.currency,
    required this.employeeIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'period_number': periodNumber,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'pay_date': payDate.toIso8601String().split('T')[0],
      'currency': currency,
      'employee_ids': employeeIds,
    };
  }
}

class UpdatePayrollEntryRequest {
  final String entryId;
  final double? baseSalary;
  final double? overtimeHours;
  final double? overtimeRate;
  final double? bonusAmount;
  final Map<String, double>? allowances;
  final Map<String, double>? deductions;

  const UpdatePayrollEntryRequest({
    required this.entryId,
    this.baseSalary,
    this.overtimeHours,
    this.overtimeRate,
    this.bonusAmount,
    this.allowances,
    this.deductions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'entry_id': entryId,
    };

    if (baseSalary != null) json['base_salary'] = baseSalary;
    if (overtimeHours != null) json['overtime_hours'] = overtimeHours;
    if (overtimeRate != null) json['overtime_rate'] = overtimeRate;
    if (bonusAmount != null) json['bonus_amount'] = bonusAmount;
    if (allowances != null) json['allowances'] = allowances;
    if (deductions != null) json['deductions'] = deductions;

    return json;
  }
}
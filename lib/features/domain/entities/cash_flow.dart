// lib/features/domain/entities/cash_flow.dart

class CashFlow {
  final String id;
  final String reportType;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final CashFlowSummary summary;
  final List<OperatingActivity> operatingActivities;
  final List<InvestingActivity> investingActivities;
  final List<FinancingActivity> financingActivities;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? generatedAt;

  const CashFlow({
    required this.id,
    required this.reportType,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    required this.summary,
    required this.operatingActivities,
    required this.investingActivities,
    required this.financingActivities,
    required this.metadata,
    required this.createdAt,
    this.generatedAt,
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'] as String,
      reportType: json['report_type'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currency: json['currency'] as String? ?? 'USD',
      summary: CashFlowSummary.fromJson(json['summary'] as Map<String, dynamic>),
      operatingActivities: (json['operating_activities'] as List<dynamic>)
          .map((o) => OperatingActivity.fromJson(o as Map<String, dynamic>))
          .toList(),
      investingActivities: (json['investing_activities'] as List<dynamic>)
          .map((i) => InvestingActivity.fromJson(i as Map<String, dynamic>))
          .toList(),
      financingActivities: (json['financing_activities'] as List<dynamic>)
          .map((f) => FinancingActivity.fromJson(f as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      generatedAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'report_date': reportDate.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'currency': currency,
      'summary': summary.toJson(),
      'operating_activities': operatingActivities.map((o) => o.toJson()).toList(),
      'investing_activities': investingActivities.map((i) => i.toJson()).toList(),
      'financing_activities': financingActivities.map((f) => f.toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}

class CashFlowSummary {
  final double netCashFromOperations;
  final double netCashFromInvesting;
  final double netCashFromFinancing;
  final double netChangeInCash;
  final double beginningCash;
  final double endingCash;
  final Map<String, double> operatingBreakdown;
  final Map<String, double> investingBreakdown;
  final Map<String, double> financingBreakdown;

  const CashFlowSummary({
    required this.netCashFromOperations,
    required this.netCashFromInvesting,
    required this.netCashFromFinancing,
    required this.netChangeInCash,
    required this.beginningCash,
    required this.endingCash,
    required this.operatingBreakdown,
    required this.investingBreakdown,
    required this.financingBreakdown,
  });

  factory CashFlowSummary.fromJson(Map<String, dynamic> json) {
    return CashFlowSummary(
      netCashFromOperations: (json['net_cash_from_operations'] as num).toDouble(),
      netCashFromInvesting: (json['net_cash_from_investing'] as num).toDouble(),
      netCashFromFinancing: (json['net_cash_from_financing'] as num).toDouble(),
      netChangeInCash: (json['net_change_in_cash'] as num).toDouble(),
      beginningCash: (json['beginning_cash'] as num).toDouble(),
      endingCash: (json['ending_cash'] as num).toDouble(),
      operatingBreakdown: Map<String, double>.from(json['operating_breakdown'] as Map<String, dynamic>),
      investingBreakdown: Map<String, double>.from(json['investing_breakdown'] as Map<String, dynamic>),
      financingBreakdown: Map<String, double>.from(json['financing_breakdown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'net_cash_from_operations': netCashFromOperations,
      'net_cash_from_investing': netCashFromInvesting,
      'net_cash_from_financing': netCashFromFinancing,
      'net_change_in_cash': netChangeInCash,
      'beginning_cash': beginningCash,
      'ending_cash': endingCash,
      'operating_breakdown': operatingBreakdown,
      'investing_breakdown': investingBreakdown,
      'financing_breakdown': financingBreakdown,
    };
  }
}

class OperatingActivity {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime transactionDate;
  final String currency;
  final String? reference;
  final Map<String, dynamic> metadata;

  const OperatingActivity({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.transactionDate,
    required this.currency,
    this.reference,
    required this.metadata,
  });

  factory OperatingActivity.fromJson(Map<String, dynamic> json) {
    return OperatingActivity(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      currency: json['currency'] as String? ?? 'USD',
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

class InvestingActivity {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime transactionDate;
  final String currency;
  final String? reference;
  final Map<String, dynamic> metadata;

  const InvestingActivity({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.transactionDate,
    required this.currency,
    this.reference,
    required this.metadata,
  });

  factory InvestingActivity.fromJson(Map<String, dynamic> json) {
    return InvestingActivity(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      currency: json['currency'] as String? ?? 'USD',
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

class FinancingActivity {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime transactionDate;
  final String currency;
  final String? reference;
  final Map<String, dynamic> metadata;

  const FinancingActivity({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.transactionDate,
    required this.currency,
    this.reference,
    required this.metadata,
  });

  factory FinancingActivity.fromJson(Map<String, dynamic> json) {
    return FinancingActivity(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      currency: json['currency'] as String? ?? 'USD',
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

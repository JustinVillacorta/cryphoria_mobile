// lib/features/domain/entities/cash_flow.dart

class CashFlowListResponse {
  final bool success;
  final List<CashFlow> cashFlowStatements;
  final int count;

  const CashFlowListResponse({
    required this.success,
    required this.cashFlowStatements,
    required this.count,
  });

  factory CashFlowListResponse.fromJson(Map<String, dynamic> json) {
    return CashFlowListResponse(
      success: json['success'] as bool,
      cashFlowStatements: (json['cash_flow_statements'] as List<dynamic>)
          .map((e) => CashFlow.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'cash_flow_statements': cashFlowStatements.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class CashFlow {
  final String id;
  final String cashFlowId;
  final String userId;
  final String reportType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String currency;
  final OperatingActivities operatingActivities;
  final InvestingActivities investingActivities;
  final FinancingActivities financingActivities;
  final CashSummary cashSummary;
  final CashFlowAnalysis analysis;
  final CashFlowMetadata metadata;

  const CashFlow({
    required this.id,
    required this.cashFlowId,
    required this.userId,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.currency,
    required this.operatingActivities,
    required this.investingActivities,
    required this.financingActivities,
    required this.cashSummary,
    required this.analysis,
    required this.metadata,
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['_id'] as String,
      cashFlowId: json['cash_flow_id'] as String,
      userId: json['user_id'] as String,
      reportType: json['report_type'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      currency: json['currency'] as String,
      operatingActivities: OperatingActivities.fromJson(json['operating_activities'] as Map<String, dynamic>),
      investingActivities: InvestingActivities.fromJson(json['investing_activities'] as Map<String, dynamic>),
      financingActivities: FinancingActivities.fromJson(json['financing_activities'] as Map<String, dynamic>),
      cashSummary: CashSummary.fromJson(json['cash_summary'] as Map<String, dynamic>),
      analysis: CashFlowAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      metadata: CashFlowMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cash_flow_id': cashFlowId,
      'user_id': userId,
      'report_type': reportType,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'currency': currency,
      'operating_activities': operatingActivities.toJson(),
      'investing_activities': investingActivities.toJson(),
      'financing_activities': financingActivities.toJson(),
      'cash_summary': cashSummary.toJson(),
      'analysis': analysis.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class OperatingActivities {
  final OperatingBreakdown cashReceipts;
  final OperatingBreakdown cashPayments;
  final double netCashFlow;

  const OperatingActivities({
    required this.cashReceipts,
    required this.cashPayments,
    required this.netCashFlow,
  });

  factory OperatingActivities.fromJson(Map<String, dynamic> json) {
    return OperatingActivities(
      cashReceipts: OperatingBreakdown.fromJson(json['cash_receipts'] as Map<String, dynamic>),
      cashPayments: OperatingBreakdown.fromJson(json['cash_payments'] as Map<String, dynamic>),
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': cashReceipts.toJson(),
      'cash_payments': cashPayments.toJson(),
      'net_cash_flow': netCashFlow,
    };
  }
}

class InvestingActivities {
  final InvestingBreakdown cashReceipts;
  final InvestingBreakdown cashPayments;
  final double netCashFlow;

  const InvestingActivities({
    required this.cashReceipts,
    required this.cashPayments,
    required this.netCashFlow,
  });

  factory InvestingActivities.fromJson(Map<String, dynamic> json) {
    return InvestingActivities(
      cashReceipts: InvestingBreakdown.fromJson(json['cash_receipts'] as Map<String, dynamic>),
      cashPayments: InvestingBreakdown.fromJson(json['cash_payments'] as Map<String, dynamic>),
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': cashReceipts.toJson(),
      'cash_payments': cashPayments.toJson(),
      'net_cash_flow': netCashFlow,
    };
  }
}

class FinancingActivities {
  final FinancingBreakdown cashReceipts;
  final FinancingBreakdown cashPayments;
  final double netCashFlow;

  const FinancingActivities({
    required this.cashReceipts,
    required this.cashPayments,
    required this.netCashFlow,
  });

  factory FinancingActivities.fromJson(Map<String, dynamic> json) {
    return FinancingActivities(
      cashReceipts: FinancingBreakdown.fromJson(json['cash_receipts'] as Map<String, dynamic>),
      cashPayments: FinancingBreakdown.fromJson(json['cash_payments'] as Map<String, dynamic>),
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': cashReceipts.toJson(),
      'cash_payments': cashPayments.toJson(),
      'net_cash_flow': netCashFlow,
    };
  }
}

class OperatingBreakdown {
  // Receipts fields
  final double customerPayments;
  final double invoiceCollections;
  final double otherIncome;
  final double total;

  // Payments fields
  final double payrollPayments;
  final double supplierPayments;
  final double operatingExpenses;
  final double taxPayments;
  final double otherExpenses;

  const OperatingBreakdown({
    this.customerPayments = 0.0,
    this.invoiceCollections = 0.0,
    this.otherIncome = 0.0,
    this.total = 0.0,
    this.payrollPayments = 0.0,
    this.supplierPayments = 0.0,
    this.operatingExpenses = 0.0,
    this.taxPayments = 0.0,
    this.otherExpenses = 0.0,
  });

  factory OperatingBreakdown.fromJson(Map<String, dynamic> json) {
    return OperatingBreakdown(
      customerPayments: (json['customer_payments'] as num?)?.toDouble() ?? 0.0,
      invoiceCollections: (json['invoice_collections'] as num?)?.toDouble() ?? 0.0,
      otherIncome: (json['other_income'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      payrollPayments: (json['payroll_payments'] as num?)?.toDouble() ?? 0.0,
      supplierPayments: (json['supplier_payments'] as num?)?.toDouble() ?? 0.0,
      operatingExpenses: (json['operating_expenses'] as num?)?.toDouble() ?? 0.0,
      taxPayments: (json['tax_payments'] as num?)?.toDouble() ?? 0.0,
      otherExpenses: (json['other_expenses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_payments': customerPayments,
      'invoice_collections': invoiceCollections,
      'other_income': otherIncome,
      'total': total,
      'payroll_payments': payrollPayments,
      'supplier_payments': supplierPayments,
      'operating_expenses': operatingExpenses,
      'tax_payments': taxPayments,
      'other_expenses': otherExpenses,
    };
  }
}

class InvestingBreakdown {
  // Receipts fields
  final double assetSales;
  final double investmentReturns;
  final double cryptoSales;
  final double total;

  // Payments fields
  final double assetPurchases;
  final double cryptoPurchases;
  final double investmentPurchases;

  const InvestingBreakdown({
    this.assetSales = 0.0,
    this.investmentReturns = 0.0,
    this.cryptoSales = 0.0,
    this.total = 0.0,
    this.assetPurchases = 0.0,
    this.cryptoPurchases = 0.0,
    this.investmentPurchases = 0.0,
  });

  factory InvestingBreakdown.fromJson(Map<String, dynamic> json) {
    return InvestingBreakdown(
      assetSales: (json['asset_sales'] as num?)?.toDouble() ?? 0.0,
      investmentReturns: (json['investment_returns'] as num?)?.toDouble() ?? 0.0,
      cryptoSales: (json['crypto_sales'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      assetPurchases: (json['asset_purchases'] as num?)?.toDouble() ?? 0.0,
      cryptoPurchases: (json['crypto_purchases'] as num?)?.toDouble() ?? 0.0,
      investmentPurchases: (json['investment_purchases'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_sales': assetSales,
      'investment_returns': investmentReturns,
      'crypto_sales': cryptoSales,
      'total': total,
      'asset_purchases': assetPurchases,
      'crypto_purchases': cryptoPurchases,
      'investment_purchases': investmentPurchases,
    };
  }
}

class FinancingBreakdown {
  // Receipts fields
  final double ownerContributions;
  final double loansReceived;
  final double otherFinancing;
  final double total;

  // Payments fields
  final double ownerWithdrawals;
  final double loanPayments;
  final double dividendPayments;

  const FinancingBreakdown({
    this.ownerContributions = 0.0,
    this.loansReceived = 0.0,
    this.otherFinancing = 0.0,
    this.total = 0.0,
    this.ownerWithdrawals = 0.0,
    this.loanPayments = 0.0,
    this.dividendPayments = 0.0,
  });

  factory FinancingBreakdown.fromJson(Map<String, dynamic> json) {
    return FinancingBreakdown(
      ownerContributions: (json['owner_contributions'] as num?)?.toDouble() ?? 0.0,
      loansReceived: (json['loans_received'] as num?)?.toDouble() ?? 0.0,
      otherFinancing: (json['other_financing'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      ownerWithdrawals: (json['owner_withdrawals'] as num?)?.toDouble() ?? 0.0,
      loanPayments: (json['loan_payments'] as num?)?.toDouble() ?? 0.0,
      dividendPayments: (json['dividend_payments'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_contributions': ownerContributions,
      'loans_received': loansReceived,
      'other_financing': otherFinancing,
      'total': total,
      'owner_withdrawals': ownerWithdrawals,
      'loan_payments': loanPayments,
      'dividend_payments': dividendPayments,
    };
  }
}

class CashSummary {
  final double beginningCash;
  final double netCashFromOperations;
  final double netCashFromInvesting;
  final double netCashFromFinancing;
  final double netChangeInCash;
  final double endingCash;

  const CashSummary({
    required this.beginningCash,
    required this.netCashFromOperations,
    required this.netCashFromInvesting,
    required this.netCashFromFinancing,
    required this.netChangeInCash,
    required this.endingCash,
  });

  factory CashSummary.fromJson(Map<String, dynamic> json) {
    return CashSummary(
      beginningCash: (json['beginning_cash'] as num).toDouble(),
      netCashFromOperations: (json['net_cash_from_operations'] as num).toDouble(),
      netCashFromInvesting: (json['net_cash_from_investing'] as num).toDouble(),
      netCashFromFinancing: (json['net_cash_from_financing'] as num).toDouble(),
      netChangeInCash: (json['net_change_in_cash'] as num).toDouble(),
      endingCash: (json['ending_cash'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beginning_cash': beginningCash,
      'net_cash_from_operations': netCashFromOperations,
      'net_cash_from_investing': netCashFromInvesting,
      'net_cash_from_financing': netCashFromFinancing,
      'net_change_in_cash': netChangeInCash,
      'ending_cash': endingCash,
    };
  }
}

class CashFlowAnalysis {
  final String cashFlowHealth;
  final double operatingCashRatio;
  final double freeCashFlow;
  final CashFlowComposition cashFlowComposition;
  final String liquidityPosition;
  final List<String> keyInsights;

  const CashFlowAnalysis({
    required this.cashFlowHealth,
    required this.operatingCashRatio,
    required this.freeCashFlow,
    required this.cashFlowComposition,
    required this.liquidityPosition,
    required this.keyInsights,
  });

  factory CashFlowAnalysis.fromJson(Map<String, dynamic> json) {
    return CashFlowAnalysis(
      cashFlowHealth: json['cash_flow_health'] as String,
      operatingCashRatio: (json['operating_cash_ratio'] as num).toDouble(),
      freeCashFlow: (json['free_cash_flow'] as num).toDouble(),
      cashFlowComposition: CashFlowComposition.fromJson(json['cash_flow_composition'] as Map<String, dynamic>),
      liquidityPosition: json['liquidity_position'] as String,
      keyInsights: (json['key_insights'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_flow_health': cashFlowHealth,
      'operating_cash_ratio': operatingCashRatio,
      'free_cash_flow': freeCashFlow,
      'cash_flow_composition': cashFlowComposition.toJson(),
      'liquidity_position': liquidityPosition,
      'key_insights': keyInsights,
    };
  }
}

class CashFlowComposition {
  final double operatingPercentage;
  final double investingPercentage;
  final double financingPercentage;

  const CashFlowComposition({
    required this.operatingPercentage,
    required this.investingPercentage,
    required this.financingPercentage,
  });

  factory CashFlowComposition.fromJson(Map<String, dynamic> json) {
    return CashFlowComposition(
      operatingPercentage: (json['operating_percentage'] as num).toDouble(),
      investingPercentage: (json['investing_percentage'] as num).toDouble(),
      financingPercentage: (json['financing_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operating_percentage': operatingPercentage,
      'investing_percentage': investingPercentage,
      'financing_percentage': financingPercentage,
    };
  }
}

class CashFlowMetadata {
  final int transactionCount;
  final int payrollEntries;
  final int invoicePayments;
  final int periodDays;

  const CashFlowMetadata({
    required this.transactionCount,
    required this.payrollEntries,
    required this.invoicePayments,
    required this.periodDays,
  });

  factory CashFlowMetadata.fromJson(Map<String, dynamic> json) {
    return CashFlowMetadata(
      transactionCount: json['transaction_count'] as int,
      payrollEntries: json['payroll_entries'] as int,
      invoicePayments: json['invoice_payments'] as int,
      periodDays: json['period_days'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'payroll_entries': payrollEntries,
      'invoice_payments': invoicePayments,
      'period_days': periodDays,
    };
  }
}
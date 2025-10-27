
import '../../domain/entities/cash_flow.dart';

class CashFlowListResponseModel extends CashFlowListResponse {
  const CashFlowListResponseModel({
    required super.success,
    required super.cashFlowStatements,
    required super.count,
  });

  factory CashFlowListResponseModel.fromJson(Map<String, dynamic> json) {
    return CashFlowListResponseModel(
      success: json['success'] as bool? ?? false,
      cashFlowStatements: (json['cash_flow_statements'] as List<dynamic>?)
          ?.map((e) => CashFlowModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      count: json['count'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'cash_flow_statements': cashFlowStatements.map((e) => (e as CashFlowModel).toJson()).toList(),
      'count': count,
    };
  }

  CashFlowListResponse toEntity() {
    return CashFlowListResponse(
      success: success,
      cashFlowStatements: cashFlowStatements.map((e) => (e as CashFlowModel).toEntity()).toList(),
      count: count,
    );
  }
}

class CashFlowModel extends CashFlow {
  const CashFlowModel({
    required super.id,
    required super.cashFlowId,
    required super.userId,
    required super.reportType,
    required super.periodStart,
    required super.periodEnd,
    required super.generatedAt,
    required super.currency,
    required super.operatingActivities,
    required super.investingActivities,
    required super.financingActivities,
    required super.cashSummary,
    required super.analysis,
    required super.metadata,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> operatingActivitiesData;
    Map<String, dynamic> investingActivitiesData;
    Map<String, dynamic> financingActivitiesData;

    if (json.containsKey('cash_flows')) {
      final cashFlows = json['cash_flows'] as Map<String, dynamic>? ?? {};
      operatingActivitiesData = cashFlows['operating_activities'] as Map<String, dynamic>? ?? {};
      investingActivitiesData = cashFlows['investing_activities'] as Map<String, dynamic>? ?? {};
      financingActivitiesData = cashFlows['financing_activities'] as Map<String, dynamic>? ?? {};
    } else {
      operatingActivitiesData = json['operating_activities'] as Map<String, dynamic>? ?? {};
      investingActivitiesData = json['investing_activities'] as Map<String, dynamic>? ?? {};
      financingActivitiesData = json['financing_activities'] as Map<String, dynamic>? ?? {};
    }

    return CashFlowModel(
      id: json['_id'] as String? ?? '',
      cashFlowId: json['cash_flow_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      reportType: json['report_type'] as String? ?? '',
      periodStart: DateTime.parse(json['period_start'] as String? ?? DateTime.now().toIso8601String()),
      periodEnd: DateTime.parse(json['period_end'] as String? ?? DateTime.now().toIso8601String()),
      generatedAt: DateTime.parse(json['generated_at'] as String? ?? DateTime.now().toIso8601String()),
      currency: json['currency'] as String? ?? 'USD',
      operatingActivities: OperatingActivitiesModel.fromJson(operatingActivitiesData),
      investingActivities: InvestingActivitiesModel.fromJson(investingActivitiesData),
      financingActivities: FinancingActivitiesModel.fromJson(financingActivitiesData),
      cashSummary: CashSummaryModel.fromJson(json['cash_summary'] as Map<String, dynamic>? ?? {}),
      analysis: CashFlowAnalysisModel.fromJson(json['analysis'] as Map<String, dynamic>? ?? {}),
      metadata: CashFlowMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
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
      'operating_activities': (operatingActivities as OperatingActivitiesModel).toJson(),
      'investing_activities': (investingActivities as InvestingActivitiesModel).toJson(),
      'financing_activities': (financingActivities as FinancingActivitiesModel).toJson(),
      'cash_summary': (cashSummary as CashSummaryModel).toJson(),
      'analysis': (analysis as CashFlowAnalysisModel).toJson(),
      'metadata': (metadata as CashFlowMetadataModel).toJson(),
    };
  }

  CashFlow toEntity() {
    return CashFlow(
      id: id,
      cashFlowId: cashFlowId,
      userId: userId,
      reportType: reportType,
      periodStart: periodStart,
      periodEnd: periodEnd,
      generatedAt: generatedAt,
      currency: currency,
      operatingActivities: operatingActivities,
      investingActivities: investingActivities,
      financingActivities: financingActivities,
      cashSummary: cashSummary,
      analysis: analysis,
      metadata: metadata,
    );
  }
}

class OperatingActivitiesModel extends OperatingActivities {
  const OperatingActivitiesModel({
    required super.cashReceipts,
    required super.cashPayments,
    required super.netCashFlow,
  });

  factory OperatingActivitiesModel.fromJson(Map<String, dynamic> json) {
    return OperatingActivitiesModel(
      cashReceipts: OperatingBreakdownModel.fromJson(json['cash_receipts'] as Map<String, dynamic>? ?? {}),
      cashPayments: OperatingBreakdownModel.fromJson(json['cash_payments'] as Map<String, dynamic>? ?? {}),
      netCashFlow: (json['net_cash_from_operations'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': (cashReceipts as OperatingBreakdownModel).toJson(),
      'cash_payments': (cashPayments as OperatingBreakdownModel).toJson(),
      'net_cash_flow': netCashFlow,
    };
  }

  OperatingActivities toEntity() {
    return OperatingActivities(
      cashReceipts: cashReceipts,
      cashPayments: cashPayments,
      netCashFlow: netCashFlow,
    );
  }
}

class InvestingActivitiesModel extends InvestingActivities {
  const InvestingActivitiesModel({
    required super.cashReceipts,
    required super.cashPayments,
    required super.netCashFlow,
  });

  factory InvestingActivitiesModel.fromJson(Map<String, dynamic> json) {
    return InvestingActivitiesModel(
      cashReceipts: InvestingBreakdownModel.fromJson(json['cash_receipts'] as Map<String, dynamic>? ?? {}),
      cashPayments: InvestingBreakdownModel.fromJson(json['cash_payments'] as Map<String, dynamic>? ?? {}),
      netCashFlow: (json['net_cash_from_investing'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': (cashReceipts as InvestingBreakdownModel).toJson(),
      'cash_payments': (cashPayments as InvestingBreakdownModel).toJson(),
      'net_cash_flow': netCashFlow,
    };
  }

  InvestingActivities toEntity() {
    return InvestingActivities(
      cashReceipts: cashReceipts,
      cashPayments: cashPayments,
      netCashFlow: netCashFlow,
    );
  }
}

class FinancingActivitiesModel extends FinancingActivities {
  const FinancingActivitiesModel({
    required super.cashReceipts,
    required super.cashPayments,
    required super.netCashFlow,
  });

  factory FinancingActivitiesModel.fromJson(Map<String, dynamic> json) {
    return FinancingActivitiesModel(
      cashReceipts: FinancingBreakdownModel.fromJson(json['cash_receipts'] as Map<String, dynamic>? ?? {}),
      cashPayments: FinancingBreakdownModel.fromJson(json['cash_payments'] as Map<String, dynamic>? ?? {}),
      netCashFlow: (json['net_cash_from_financing'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cash_receipts': (cashReceipts as FinancingBreakdownModel).toJson(),
      'cash_payments': (cashPayments as FinancingBreakdownModel).toJson(),
      'net_cash_flow': netCashFlow,
    };
  }

  FinancingActivities toEntity() {
    return FinancingActivities(
      cashReceipts: cashReceipts,
      cashPayments: cashPayments,
      netCashFlow: netCashFlow,
    );
  }
}

class OperatingBreakdownModel extends OperatingBreakdown {
  const OperatingBreakdownModel({
    super.customerPayments = 0.0,
    super.invoiceCollections = 0.0,
    super.otherIncome = 0.0,
    super.total = 0.0,
    super.payrollPayments = 0.0,
    super.supplierPayments = 0.0,
    super.operatingExpenses = 0.0,
    super.taxPayments = 0.0,
    super.otherExpenses = 0.0,
  });

  factory OperatingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return OperatingBreakdownModel(
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

  @override
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

  OperatingBreakdown toEntity() {
    return OperatingBreakdown(
      customerPayments: customerPayments,
      invoiceCollections: invoiceCollections,
      otherIncome: otherIncome,
      total: total,
      payrollPayments: payrollPayments,
      supplierPayments: supplierPayments,
      operatingExpenses: operatingExpenses,
      taxPayments: taxPayments,
      otherExpenses: otherExpenses,
    );
  }
}

class InvestingBreakdownModel extends InvestingBreakdown {
  const InvestingBreakdownModel({
    super.assetSales = 0.0,
    super.investmentReturns = 0.0,
    super.cryptoSales = 0.0,
    super.total = 0.0,
    super.assetPurchases = 0.0,
    super.cryptoPurchases = 0.0,
    super.investmentPurchases = 0.0,
  });

  factory InvestingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return InvestingBreakdownModel(
      assetSales: (json['asset_sales'] as num?)?.toDouble() ?? 0.0,
      investmentReturns: (json['investment_returns'] as num?)?.toDouble() ?? 0.0,
      cryptoSales: (json['crypto_sales'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      assetPurchases: (json['asset_purchases'] as num?)?.toDouble() ?? 0.0,
      cryptoPurchases: (json['crypto_purchases'] as num?)?.toDouble() ?? 0.0,
      investmentPurchases: (json['investment_purchases'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
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

  InvestingBreakdown toEntity() {
    return InvestingBreakdown(
      assetSales: assetSales,
      investmentReturns: investmentReturns,
      cryptoSales: cryptoSales,
      total: total,
      assetPurchases: assetPurchases,
      cryptoPurchases: cryptoPurchases,
      investmentPurchases: investmentPurchases,
    );
  }
}

class FinancingBreakdownModel extends FinancingBreakdown {
  const FinancingBreakdownModel({
    super.ownerContributions = 0.0,
    super.loansReceived = 0.0,
    super.otherFinancing = 0.0,
    super.total = 0.0,
    super.ownerWithdrawals = 0.0,
    super.loanPayments = 0.0,
    super.dividendPayments = 0.0,
  });

  factory FinancingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FinancingBreakdownModel(
      ownerContributions: (json['owner_contributions'] as num?)?.toDouble() ?? 0.0,
      loansReceived: (json['loans_received'] as num?)?.toDouble() ?? 0.0,
      otherFinancing: (json['other_financing'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      ownerWithdrawals: (json['owner_withdrawals'] as num?)?.toDouble() ?? 0.0,
      loanPayments: (json['loan_payments'] as num?)?.toDouble() ?? 0.0,
      dividendPayments: (json['dividend_payments'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
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

  FinancingBreakdown toEntity() {
    return FinancingBreakdown(
      ownerContributions: ownerContributions,
      loansReceived: loansReceived,
      otherFinancing: otherFinancing,
      total: total,
      ownerWithdrawals: ownerWithdrawals,
      loanPayments: loanPayments,
      dividendPayments: dividendPayments,
    );
  }
}



class CashSummaryModel extends CashSummary {
  const CashSummaryModel({
    required super.beginningCash,
    required super.netCashFromOperations,
    required super.netCashFromInvesting,
    required super.netCashFromFinancing,
    required super.netChangeInCash,
    required super.endingCash,
  });

  factory CashSummaryModel.fromJson(Map<String, dynamic> json) {
    return CashSummaryModel(
      beginningCash: _safeToDouble(json['cash_at_beginning']),
      netCashFromOperations: _safeToDouble(json['net_cash_from_operations']),
      netCashFromInvesting: _safeToDouble(json['net_cash_from_investing']),
      netCashFromFinancing: _safeToDouble(json['net_cash_from_financing']),
      netChangeInCash: _safeToDouble(json['net_change_in_cash']),
      endingCash: _safeToDouble(json['cash_at_end']),
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  @override
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

  CashSummary toEntity() {
    return CashSummary(
      beginningCash: beginningCash,
      netCashFromOperations: netCashFromOperations,
      netCashFromInvesting: netCashFromInvesting,
      netCashFromFinancing: netCashFromFinancing,
      netChangeInCash: netChangeInCash,
      endingCash: endingCash,
    );
  }
}

class CashFlowAnalysisModel extends CashFlowAnalysis {
  const CashFlowAnalysisModel({
    required super.cashFlowHealth,
    required super.operatingCashRatio,
    required super.freeCashFlow,
    required super.cashFlowComposition,
    required super.liquidityPosition,
    required super.keyInsights,
  });

  factory CashFlowAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CashFlowAnalysisModel(
      cashFlowHealth: json['cash_flow_health'] as String? ?? 'Unknown',
      operatingCashRatio: _safeToDouble(json['operating_cash_ratio']),
      freeCashFlow: _safeToDouble(json['free_cash_flow']),
      cashFlowComposition: CashFlowCompositionModel.fromJson(json['cash_flow_composition'] as Map<String, dynamic>? ?? {}),
      liquidityPosition: json['liquidity_position'] as String? ?? 'Unknown',
      keyInsights: (json['key_insights'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cash_flow_health': cashFlowHealth,
      'operating_cash_ratio': operatingCashRatio,
      'free_cash_flow': freeCashFlow,
      'cash_flow_composition': (cashFlowComposition as CashFlowCompositionModel).toJson(),
      'liquidity_position': liquidityPosition,
      'key_insights': keyInsights,
    };
  }

  CashFlowAnalysis toEntity() {
    return CashFlowAnalysis(
      cashFlowHealth: cashFlowHealth,
      operatingCashRatio: operatingCashRatio,
      freeCashFlow: freeCashFlow,
      cashFlowComposition: cashFlowComposition,
      liquidityPosition: liquidityPosition,
      keyInsights: keyInsights,
    );
  }
}

class CashFlowCompositionModel extends CashFlowComposition {
  const CashFlowCompositionModel({
    required super.operatingPercentage,
    required super.investingPercentage,
    required super.financingPercentage,
  });

  factory CashFlowCompositionModel.fromJson(Map<String, dynamic> json) {
    return CashFlowCompositionModel(
      operatingPercentage: _safeToDouble(json['operating_percentage']),
      investingPercentage: _safeToDouble(json['investing_percentage']),
      financingPercentage: _safeToDouble(json['financing_percentage']),
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'operating_percentage': operatingPercentage,
      'investing_percentage': investingPercentage,
      'financing_percentage': financingPercentage,
    };
  }

  CashFlowComposition toEntity() {
    return CashFlowComposition(
      operatingPercentage: operatingPercentage,
      investingPercentage: investingPercentage,
      financingPercentage: financingPercentage,
    );
  }
}

class CashFlowMetadataModel extends CashFlowMetadata {
  const CashFlowMetadataModel({
    required super.transactionCount,
    required super.payrollEntries,
    required super.invoicePayments,
    required super.periodDays,
  });

  factory CashFlowMetadataModel.fromJson(Map<String, dynamic> json) {
    return CashFlowMetadataModel(
      transactionCount: json['transaction_count'] as int? ?? 0,
      payrollEntries: json['payroll_entries'] as int? ?? 0,
      invoicePayments: json['invoice_payments'] as int? ?? 0,
      periodDays: json['period_days'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'payroll_entries': payrollEntries,
      'invoice_payments': invoicePayments,
      'period_days': periodDays,
    };
  }

  CashFlowMetadata toEntity() {
    return CashFlowMetadata(
      transactionCount: transactionCount,
      payrollEntries: payrollEntries,
      invoicePayments: invoicePayments,
      periodDays: periodDays,
    );
  }
}
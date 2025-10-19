import '../../domain/entities/income_statement.dart';

class IncomeStatementModel extends IncomeStatement {
  const IncomeStatementModel({
    required super.id,
    required super.incomeStatementId,
    required super.userId,
    required super.periodStart,
    required super.periodEnd,
    required super.generatedAt,
    required super.currency,
    required super.revenue,
    required super.expenses,
    required super.grossProfit,
    required super.netIncome,
    required super.summary,
    required super.metadata,
  });

  factory IncomeStatementModel.fromJson(Map<String, dynamic> json) {
    return IncomeStatementModel(
      id: json['_id'] ?? '',
      incomeStatementId: json['income_statement_id'] ?? '',
      userId: json['user_id'] ?? '',
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      generatedAt: DateTime.parse(json['generated_at']),
      currency: json['currency'] ?? 'USD',
      revenue: RevenueData.fromJson(json['revenue'] ?? {}),
      expenses: ExpensesData.fromJson(json['expenses'] ?? {}),
      grossProfit: GrossProfitData.fromJson(json['gross_profit'] ?? {}),
      netIncome: NetIncomeData.fromJson(json['net_income'] ?? {}),
      summary: SummaryData.fromJson(json['summary'] ?? {}),
      metadata: MetadataData.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'income_statement_id': incomeStatementId,
      'user_id': userId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'currency': currency,
      'revenue': revenue.toJson(),
      'expenses': expenses.toJson(),
      'gross_profit': grossProfit.toJson(),
      'net_income': netIncome.toJson(),
      'summary': summary.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class RevenueData extends Revenue {
  const RevenueData({
    required super.totalRevenue,
    required super.tradingRevenue,
    required super.payrollIncome,
    required super.otherIncome,
    required super.byCryptocurrency,
    required super.byMonth,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      tradingRevenue: (json['trading_revenue'] ?? 0).toDouble(),
      payrollIncome: (json['payroll_income'] ?? 0).toDouble(),
      otherIncome: (json['other_income'] ?? 0).toDouble(),
      byCryptocurrency: Map<String, Map<String, double>>.from(
        (json['by_cryptocurrency'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            Map<String, double>.from(value.map(
              (k, v) => MapEntry(k, (v ?? 0).toDouble()),
            )),
          ),
        ),
      ),
      byMonth: Map<String, double>.from(
        (json['by_month'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'trading_revenue': tradingRevenue,
      'payroll_income': payrollIncome,
      'other_income': otherIncome,
      'by_cryptocurrency': byCryptocurrency,
      'by_month': byMonth,
    };
  }
}

class ExpensesData extends Expenses {
  const ExpensesData({
    required super.totalExpenses,
    required super.transactionFees,
    required super.tradingLosses,
    required super.operationalExpenses,
    required super.taxExpenses,
    required super.byCryptocurrency,
    required super.byMonth,
  });

  factory ExpensesData.fromJson(Map<String, dynamic> json) {
    return ExpensesData(
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      transactionFees: (json['transaction_fees'] ?? 0).toDouble(),
      tradingLosses: (json['trading_losses'] ?? 0).toDouble(),
      operationalExpenses: (json['operational_expenses'] ?? 0).toDouble(),
      taxExpenses: (json['tax_expenses'] ?? 0).toDouble(),
      byCryptocurrency: Map<String, Map<String, double>>.from(
        (json['by_cryptocurrency'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            Map<String, double>.from(value.map(
              (k, v) => MapEntry(k, (v ?? 0).toDouble()),
            )),
          ),
        ),
      ),
      byMonth: Map<String, double>.from(
        (json['by_month'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_expenses': totalExpenses,
      'transaction_fees': transactionFees,
      'trading_losses': tradingLosses,
      'operational_expenses': operationalExpenses,
      'tax_expenses': taxExpenses,
      'by_cryptocurrency': byCryptocurrency,
      'by_month': byMonth,
    };
  }
}

class GrossProfitData extends GrossProfit {
  const GrossProfitData({
    required super.grossProfit,
    required super.grossProfitMargin,
    required super.revenue,
    required super.costOfGoodsSold,
  });

  factory GrossProfitData.fromJson(Map<String, dynamic> json) {
    return GrossProfitData(
      grossProfit: (json['gross_profit'] ?? 0).toDouble(),
      grossProfitMargin: (json['gross_profit_margin'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
      costOfGoodsSold: (json['cost_of_goods_sold'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gross_profit': grossProfit,
      'gross_profit_margin': grossProfitMargin,
      'revenue': revenue,
      'cost_of_goods_sold': costOfGoodsSold,
    };
  }
}

class NetIncomeData extends NetIncome {
  const NetIncomeData({
    required super.netIncome,
    required super.netProfitMargin,
    required super.operatingExpenses,
    required super.taxExpenses,
    required super.isProfitable,
  });

  factory NetIncomeData.fromJson(Map<String, dynamic> json) {
    return NetIncomeData(
      netIncome: (json['net_income'] ?? 0).toDouble(),
      netProfitMargin: (json['net_profit_margin'] ?? 0).toDouble(),
      operatingExpenses: (json['operating_expenses'] ?? 0).toDouble(),
      taxExpenses: (json['tax_expenses'] ?? 0).toDouble(),
      isProfitable: json['is_profitable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'net_income': netIncome,
      'net_profit_margin': netProfitMargin,
      'operating_expenses': operatingExpenses,
      'tax_expenses': taxExpenses,
      'is_profitable': isProfitable,
    };
  }
}

class SummaryData extends Summary {
  const SummaryData({
    required super.periodSummary,
    required super.profitabilityStatus,
    required super.netIncomeAmount,
    required super.primaryRevenueSource,
    required super.expenseBreakdown,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      periodSummary: json['period_summary'] ?? '',
      profitabilityStatus: json['profitability_status'] ?? '',
      netIncomeAmount: (json['net_income_amount'] ?? 0).toDouble(),
      primaryRevenueSource: json['primary_revenue_source'] ?? '',
      expenseBreakdown: Map<String, double>.from(
        (json['expense_breakdown'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_summary': periodSummary,
      'profitability_status': profitabilityStatus,
      'net_income_amount': netIncomeAmount,
      'primary_revenue_source': primaryRevenueSource,
      'expense_breakdown': expenseBreakdown,
    };
  }
}

class MetadataData extends Metadata {
  const MetadataData({
    required super.transactionCount,
    required super.payrollCount,
    required super.periodLengthDays,
  });

  factory MetadataData.fromJson(Map<String, dynamic> json) {
    return MetadataData(
      transactionCount: json['transaction_count'] ?? 0,
      payrollCount: json['payroll_count'] ?? 0,
      periodLengthDays: json['period_length_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'payroll_count': payrollCount,
      'period_length_days': periodLengthDays,
    };
  }
}

class IncomeStatementsResponseModel {
  final bool success;
  final List<IncomeStatementModel> incomeStatements;
  final String? message;

  const IncomeStatementsResponseModel({
    required this.success,
    required this.incomeStatements,
    this.message,
  });

  factory IncomeStatementsResponseModel.fromJson(Map<String, dynamic> json) {
    return IncomeStatementsResponseModel(
      success: json['success'] ?? false,
      incomeStatements: (json['income_statements'] as List?)
              ?.map((item) => IncomeStatementModel.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

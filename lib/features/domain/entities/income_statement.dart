class IncomeStatement {
  final String id;
  final String incomeStatementId;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String currency;
  final Revenue revenue;
  final Expenses expenses;
  final GrossProfit grossProfit;
  final NetIncome netIncome;
  final Summary summary;
  final Metadata metadata;

  const IncomeStatement({
    required this.id,
    required this.incomeStatementId,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.currency,
    required this.revenue,
    required this.expenses,
    required this.grossProfit,
    required this.netIncome,
    required this.summary,
    required this.metadata,
  });
}

class Revenue {
  final double totalRevenue;
  final double tradingRevenue;
  final double payrollIncome;
  final double otherIncome;
  final Map<String, Map<String, double>> byCryptocurrency;
  final Map<String, double> byMonth;

  const Revenue({
    required this.totalRevenue,
    required this.tradingRevenue,
    required this.payrollIncome,
    required this.otherIncome,
    required this.byCryptocurrency,
    required this.byMonth,
  });

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

class Expenses {
  final double totalExpenses;
  final double transactionFees;
  final double tradingLosses;
  final double operationalExpenses;
  final double taxExpenses;
  final Map<String, Map<String, double>> byCryptocurrency;
  final Map<String, double> byMonth;

  const Expenses({
    required this.totalExpenses,
    required this.transactionFees,
    required this.tradingLosses,
    required this.operationalExpenses,
    required this.taxExpenses,
    required this.byCryptocurrency,
    required this.byMonth,
  });

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

class GrossProfit {
  final double grossProfit;
  final double grossProfitMargin;
  final double revenue;
  final double costOfGoodsSold;

  const GrossProfit({
    required this.grossProfit,
    required this.grossProfitMargin,
    required this.revenue,
    required this.costOfGoodsSold,
  });

  Map<String, dynamic> toJson() {
    return {
      'gross_profit': grossProfit,
      'gross_profit_margin': grossProfitMargin,
      'revenue': revenue,
      'cost_of_goods_sold': costOfGoodsSold,
    };
  }
}

class NetIncome {
  final double netIncome;
  final double netProfitMargin;
  final double operatingExpenses;
  final double taxExpenses;
  final bool isProfitable;

  const NetIncome({
    required this.netIncome,
    required this.netProfitMargin,
    required this.operatingExpenses,
    required this.taxExpenses,
    required this.isProfitable,
  });

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

class Summary {
  final String periodSummary;
  final String profitabilityStatus;
  final double netIncomeAmount;
  final String primaryRevenueSource;
  final Map<String, double> expenseBreakdown;

  const Summary({
    required this.periodSummary,
    required this.profitabilityStatus,
    required this.netIncomeAmount,
    required this.primaryRevenueSource,
    required this.expenseBreakdown,
  });

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

class Metadata {
  final int transactionCount;
  final int payrollCount;
  final int periodLengthDays;

  const Metadata({
    required this.transactionCount,
    required this.payrollCount,
    required this.periodLengthDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'payroll_count': payrollCount,
      'period_length_days': periodLengthDays,
    };
  }
}

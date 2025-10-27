
class BalanceSheet {
  final String id;
  final String balanceSheetId;
  final String userId;
  final DateTime asOfDate;
  final String reportType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String currency;
  final BalanceSheetAssets assets;
  final BalanceSheetLiabilities liabilities;
  final BalanceSheetEquity equity;
  final BalanceSheetTotals totals;
  final BalanceSheetSummary summary;
  final BalanceSheetMetadata metadata;

  const BalanceSheet({
    required this.id,
    required this.balanceSheetId,
    required this.userId,
    required this.asOfDate,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.currency,
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.totals,
    required this.summary,
    required this.metadata,
  });

  factory BalanceSheet.fromJson(Map<String, dynamic> json) {
    return BalanceSheet(
      id: json['_id']?.toString() ?? '',
      balanceSheetId: json['balance_sheet_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      asOfDate: DateTime.tryParse(json['as_of_date']?.toString() ?? '') ?? DateTime.now(),
      reportType: json['report_type']?.toString() ?? 'CUSTOM',
      periodStart: DateTime.tryParse(json['period_start']?.toString() ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['period_end']?.toString() ?? '') ?? DateTime.now(),
      generatedAt: DateTime.tryParse(json['generated_at']?.toString() ?? '') ?? DateTime.now(),
      currency: json['currency']?.toString() ?? 'USD',
      assets: BalanceSheetAssets.fromJson(json['assets'] as Map<String, dynamic>? ?? {}),
      liabilities: BalanceSheetLiabilities.fromJson(json['liabilities'] as Map<String, dynamic>? ?? {}),
      equity: BalanceSheetEquity.fromJson(json['equity'] as Map<String, dynamic>? ?? {}),
      totals: BalanceSheetTotals.fromJson(json['totals'] as Map<String, dynamic>? ?? {}),
      summary: BalanceSheetSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      metadata: BalanceSheetMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'balance_sheet_id': balanceSheetId,
      'user_id': userId,
      'as_of_date': asOfDate.toIso8601String(),
      'report_type': reportType,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'currency': currency,
      'assets': assets.toJson(),
      'liabilities': liabilities.toJson(),
      'equity': equity.toJson(),
      'totals': totals.toJson(),
      'summary': summary.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class BalanceSheetAssets {
  final CurrentAssets currentAssets;
  final NonCurrentAssets nonCurrentAssets;
  final double total;

  const BalanceSheetAssets({
    required this.currentAssets,
    required this.nonCurrentAssets,
    required this.total,
  });

  factory BalanceSheetAssets.fromJson(Map<String, dynamic> json) {
    return BalanceSheetAssets(
      currentAssets: CurrentAssets.fromJson(json['current_assets'] as Map<String, dynamic>? ?? {}),
      nonCurrentAssets: NonCurrentAssets.fromJson(json['non_current_assets'] as Map<String, dynamic>? ?? {}),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_assets': currentAssets.toJson(),
      'non_current_assets': nonCurrentAssets.toJson(),
      'total': total,
    };
  }
}

class CurrentAssets {
  final CryptoHoldings cryptoHoldings;
  final double cashEquivalents;
  final int receivables;
  final double total;

  const CurrentAssets({
    required this.cryptoHoldings,
    required this.cashEquivalents,
    required this.receivables,
    required this.total,
  });

  factory CurrentAssets.fromJson(Map<String, dynamic> json) {
    return CurrentAssets(
      cryptoHoldings: CryptoHoldings.fromJson(json['crypto_holdings'] as Map<String, dynamic>? ?? {}),
      cashEquivalents: (json['cash_equivalents'] as num?)?.toDouble() ?? 0.0,
      receivables: (json['receivables'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crypto_holdings': cryptoHoldings.toJson(),
      'cash_equivalents': cashEquivalents,
      'receivables': receivables,
      'total': total,
    };
  }
}

class CryptoAsset {
  final double balance;
  final double currentPrice;
  final double currentValue;
  final double costBasis;
  final double averageCost;
  final double unrealizedGainLoss;

  const CryptoAsset({
    required this.balance,
    required this.currentPrice,
    required this.currentValue,
    required this.costBasis,
    required this.averageCost,
    required this.unrealizedGainLoss,
  });

  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    return CryptoAsset(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      costBasis: (json['cost_basis'] as num?)?.toDouble() ?? 0.0,
      averageCost: (json['average_cost'] as num?)?.toDouble() ?? 0.0,
      unrealizedGainLoss: (json['unrealized_gain_loss'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'current_price': currentPrice,
      'current_value': currentValue,
      'cost_basis': costBasis,
      'average_cost': averageCost,
      'unrealized_gain_loss': unrealizedGainLoss,
    };
  }
}

class CryptoHoldings {
  final Map<String, CryptoAsset> holdings;
  final double totalValue;

  const CryptoHoldings({
    required this.holdings,
    required this.totalValue,
  });

  factory CryptoHoldings.fromJson(Map<String, dynamic> json) {
    final Map<String, CryptoAsset> holdingsMap = {};

    json.forEach((key, value) {
      if (key != 'total_value' && value is Map<String, dynamic>) {
        holdingsMap[key] = CryptoAsset.fromJson(value);
      }
    });

    return CryptoHoldings(
      holdings: holdingsMap,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = Map<String, dynamic>.from(holdings);
    result['total_value'] = totalValue;
    return result;
  }
}

class NonCurrentAssets {
  final double longTermInvestments;
  final double equipment;
  final double other;
  final double total;

  const NonCurrentAssets({
    required this.longTermInvestments,
    required this.equipment,
    required this.other,
    required this.total,
  });

  factory NonCurrentAssets.fromJson(Map<String, dynamic> json) {
    return NonCurrentAssets(
      longTermInvestments: (json['long_term_investments'] as num?)?.toDouble() ?? 0.0,
      equipment: (json['equipment'] as num?)?.toDouble() ?? 0.0,
      other: (json['other'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'long_term_investments': longTermInvestments,
      'equipment': equipment,
      'other': other,
      'total': total,
    };
  }
}

class BalanceSheetLiabilities {
  final CurrentLiabilities currentLiabilities;
  final LongTermLiabilities longTermLiabilities;
  final double total;

  const BalanceSheetLiabilities({
    required this.currentLiabilities,
    required this.longTermLiabilities,
    required this.total,
  });

  factory BalanceSheetLiabilities.fromJson(Map<String, dynamic> json) {
    return BalanceSheetLiabilities(
      currentLiabilities: CurrentLiabilities.fromJson(json['current_liabilities'] as Map<String, dynamic>? ?? {}),
      longTermLiabilities: LongTermLiabilities.fromJson(json['long_term_liabilities'] as Map<String, dynamic>? ?? {}),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_liabilities': currentLiabilities.toJson(),
      'long_term_liabilities': longTermLiabilities.toJson(),
      'total': total,
    };
  }
}

class CurrentLiabilities {
  final int accountsPayable;
  final double accruedExpenses;
  final double shortTermDebt;
  final double taxLiabilities;
  final double total;

  const CurrentLiabilities({
    required this.accountsPayable,
    required this.accruedExpenses,
    required this.shortTermDebt,
    required this.taxLiabilities,
    required this.total,
  });

  factory CurrentLiabilities.fromJson(Map<String, dynamic> json) {
    return CurrentLiabilities(
      accountsPayable: (json['accounts_payable'] as num?)?.toInt() ?? 0,
      accruedExpenses: (json['accrued_expenses'] as num?)?.toDouble() ?? 0.0,
      shortTermDebt: (json['short_term_debt'] as num?)?.toDouble() ?? 0.0,
      taxLiabilities: (json['tax_liabilities'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts_payable': accountsPayable,
      'accrued_expenses': accruedExpenses,
      'short_term_debt': shortTermDebt,
      'tax_liabilities': taxLiabilities,
      'total': total,
    };
  }
}

class LongTermLiabilities {
  final double longTermDebt;
  final double deferredTax;
  final double other;
  final double total;

  const LongTermLiabilities({
    required this.longTermDebt,
    required this.deferredTax,
    required this.other,
    required this.total,
  });

  factory LongTermLiabilities.fromJson(Map<String, dynamic> json) {
    return LongTermLiabilities(
      longTermDebt: (json['long_term_debt'] as num?)?.toDouble() ?? 0.0,
      deferredTax: (json['deferred_tax'] as num?)?.toDouble() ?? 0.0,
      other: (json['other'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'long_term_debt': longTermDebt,
      'deferred_tax': deferredTax,
      'other': other,
      'total': total,
    };
  }
}

class BalanceSheetEquity {
  final int retainedEarnings;
  final double unrealizedGainsLosses;
  final double total;

  const BalanceSheetEquity({
    required this.retainedEarnings,
    required this.unrealizedGainsLosses,
    required this.total,
  });

  factory BalanceSheetEquity.fromJson(Map<String, dynamic> json) {
    return BalanceSheetEquity(
      retainedEarnings: (json['retained_earnings'] as num?)?.toInt() ?? 0,
      unrealizedGainsLosses: (json['unrealized_gains_losses'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retained_earnings': retainedEarnings,
      'unrealized_gains_losses': unrealizedGainsLosses,
      'total': total,
    };
  }
}

class BalanceSheetTotals {
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final double balanceCheck;

  const BalanceSheetTotals({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.balanceCheck,
  });

  factory BalanceSheetTotals.fromJson(Map<String, dynamic> json) {
    return BalanceSheetTotals(
      totalAssets: (json['total_assets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities: (json['total_liabilities'] as num?)?.toDouble() ?? 0.0,
      totalEquity: (json['total_equity'] as num?)?.toDouble() ?? 0.0,
      balanceCheck: (json['balance_check'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'total_equity': totalEquity,
      'balance_check': balanceCheck,
    };
  }
}

class BalanceSheetSummary {
  final String financialPosition;
  final String debtToEquityRatio;
  final AssetComposition assetComposition;
  final String liquidityRatio;
  final double netWorth;

  const BalanceSheetSummary({
    required this.financialPosition,
    required this.debtToEquityRatio,
    required this.assetComposition,
    required this.liquidityRatio,
    required this.netWorth,
  });

  factory BalanceSheetSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSheetSummary(
      financialPosition: json['financial_position']?.toString() ?? 'Unknown',
      debtToEquityRatio: json['debt_to_equity_ratio']?.toString() ?? 'Undefined',
      assetComposition: AssetComposition.fromJson(json['asset_composition'] as Map<String, dynamic>? ?? {}),
      liquidityRatio: json['liquidity_ratio']?.toString() ?? 'Unlimited',
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financial_position': financialPosition,
      'debt_to_equity_ratio': debtToEquityRatio,
      'asset_composition': assetComposition.toJson(),
      'liquidity_ratio': liquidityRatio,
      'net_worth': netWorth,
    };
  }
}

class AssetComposition {
  final int cryptoPercentage;
  final int cashPercentage;

  const AssetComposition({
    required this.cryptoPercentage,
    required this.cashPercentage,
  });

  factory AssetComposition.fromJson(Map<String, dynamic> json) {
    return AssetComposition(
      cryptoPercentage: (json['crypto_percentage'] as num?)?.toInt() ?? 0,
      cashPercentage: (json['cash_percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crypto_percentage': cryptoPercentage,
      'cash_percentage': cashPercentage,
    };
  }
}

class BalanceSheetMetadata {
  final int transactionCount;
  final DateRange dateRange;

  const BalanceSheetMetadata({
    required this.transactionCount,
    required this.dateRange,
  });

  factory BalanceSheetMetadata.fromJson(Map<String, dynamic> json) {
    return BalanceSheetMetadata(
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
      dateRange: DateRange.fromJson(json['date_range'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'date_range': dateRange.toJson(),
    };
  }
}

class DateRange {
  final DateTime earliestTransaction;
  final DateTime latestTransaction;

  const DateRange({
    required this.earliestTransaction,
    required this.latestTransaction,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      earliestTransaction: DateTime.tryParse(json['earliest_transaction']?.toString() ?? '') ?? DateTime.now(),
      latestTransaction: DateTime.tryParse(json['latest_transaction']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earliest_transaction': earliestTransaction.toIso8601String(),
      'latest_transaction': latestTransaction.toIso8601String(),
    };
  }
}
// lib/features/data/models/balance_sheet_model.dart

import '../../domain/entities/balance_sheet.dart';

class BalanceSheetModel extends BalanceSheet {
  const BalanceSheetModel({
    required super.id,
    required super.balanceSheetId,
    required super.userId,
    required super.asOfDate,
    required super.reportType,
    required super.periodStart,
    required super.periodEnd,
    required super.generatedAt,
    required super.currency,
    required super.assets,
    required super.liabilities,
    required super.equity,
    required super.totals,
    required super.summary,
    required super.metadata,
  });

  factory BalanceSheetModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetModel(
      id: json['_id']?.toString() ?? '',
      balanceSheetId: json['balance_sheet_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      asOfDate: _safeParseDateTime(json['as_of_date']),
      reportType: json['report_type']?.toString() ?? 'CUSTOM',
      periodStart: _safeParseDateTime(json['period_start']),
      periodEnd: _safeParseDateTime(json['period_end']),
      generatedAt: _safeParseDateTime(json['generated_at']),
      currency: json['currency']?.toString() ?? 'USD',
      assets: BalanceSheetAssetsModel.fromJson(_safeConvertMap(json['assets'])),
      liabilities: BalanceSheetLiabilitiesModel.fromJson(_safeConvertMap(json['liabilities'])),
      equity: BalanceSheetEquityModel.fromJson(_safeConvertMap(json['equity'])),
      totals: BalanceSheetTotalsModel.fromJson(_safeConvertMap(json['totals'])),
      summary: BalanceSheetSummaryModel.fromJson(_safeConvertMap(json['summary'])),
      metadata: BalanceSheetMetadataModel.fromJson(_safeConvertMap(json['metadata'])),
    );
  }

  static DateTime _safeParseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
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
      'assets': (assets as BalanceSheetAssetsModel).toJson(),
      'liabilities': (liabilities as BalanceSheetLiabilitiesModel).toJson(),
      'equity': (equity as BalanceSheetEquityModel).toJson(),
      'totals': (totals as BalanceSheetTotalsModel).toJson(),
      'summary': (summary as BalanceSheetSummaryModel).toJson(),
      'metadata': (metadata as BalanceSheetMetadataModel).toJson(),
    };
  }

  BalanceSheet toEntity() {
    return BalanceSheet(
      id: id,
      balanceSheetId: balanceSheetId,
      userId: userId,
      asOfDate: asOfDate,
      reportType: reportType,
      periodStart: periodStart,
      periodEnd: periodEnd,
      generatedAt: generatedAt,
      currency: currency,
      assets: assets,
      liabilities: liabilities,
      equity: equity,
      totals: totals,
      summary: summary,
      metadata: metadata,
    );
  }
}

class BalanceSheetAssetsModel extends BalanceSheetAssets {
  const BalanceSheetAssetsModel({
    required super.currentAssets,
    required super.nonCurrentAssets,
    required super.total,
  });

  factory BalanceSheetAssetsModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetAssetsModel(
      currentAssets: CurrentAssetsModel.fromJson(_safeConvertMap(json['current_assets'])),
      nonCurrentAssets: NonCurrentAssetsModel.fromJson(_safeConvertMap(json['non_current_assets'])),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'current_assets': (currentAssets as CurrentAssetsModel).toJson(),
      'non_current_assets': (nonCurrentAssets as NonCurrentAssetsModel).toJson(),
      'total': total,
    };
  }
}

class CurrentAssetsModel extends CurrentAssets {
  const CurrentAssetsModel({
    required super.cryptoHoldings,
    required super.cashEquivalents,
    required super.receivables,
    required super.total,
  });

  factory CurrentAssetsModel.fromJson(Map<String, dynamic> json) {
    return CurrentAssetsModel(
      cryptoHoldings: CryptoHoldingsModel.fromJson(_safeConvertMap(json['crypto_holdings'])),
      cashEquivalents: (json['cash_equivalents'] as num?)?.toDouble() ?? 0.0,
      receivables: (json['receivables'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'crypto_holdings': (cryptoHoldings as CryptoHoldingsModel).toJson(),
      'cash_equivalents': cashEquivalents,
      'receivables': receivables,
      'total': total,
    };
  }
}

class CryptoAssetModel extends CryptoAsset {
  const CryptoAssetModel({
    required super.balance,
    required super.currentPrice,
    required super.currentValue,
    required super.costBasis,
    required super.averageCost,
    required super.unrealizedGainLoss,
  });

  factory CryptoAssetModel.fromJson(Map<String, dynamic> json) {
    return CryptoAssetModel(
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

class CryptoHoldingsModel extends CryptoHoldings {
  const CryptoHoldingsModel({
    required super.holdings,
    required super.totalValue,
  });

  factory CryptoHoldingsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, CryptoAsset> holdingsMap = {};
    
    // Parse individual crypto holdings (e.g., ETH, BTC, etc.)
    json.forEach((key, value) {
      if (key != 'total_value' && value is Map<String, dynamic>) {
        holdingsMap[key] = CryptoAssetModel.fromJson(value);
      }
    });
    
    return CryptoHoldingsModel(
      holdings: holdingsMap,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    
    // Convert holdings to JSON
    holdings.forEach((key, value) {
      result[key] = (value as CryptoAssetModel).toJson();
    });
    
    result['total_value'] = totalValue;
    return result;
  }
}

class NonCurrentAssetsModel extends NonCurrentAssets {
  const NonCurrentAssetsModel({
    required super.longTermInvestments,
    required super.equipment,
    required super.other,
    required super.total,
  });

  factory NonCurrentAssetsModel.fromJson(Map<String, dynamic> json) {
    return NonCurrentAssetsModel(
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

class BalanceSheetLiabilitiesModel extends BalanceSheetLiabilities {
  const BalanceSheetLiabilitiesModel({
    required super.currentLiabilities,
    required super.longTermLiabilities,
    required super.total,
  });

  factory BalanceSheetLiabilitiesModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetLiabilitiesModel(
      currentLiabilities: CurrentLiabilitiesModel.fromJson(_safeConvertMap(json['current_liabilities'])),
      longTermLiabilities: LongTermLiabilitiesModel.fromJson(_safeConvertMap(json['long_term_liabilities'])),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'current_liabilities': (currentLiabilities as CurrentLiabilitiesModel).toJson(),
      'long_term_liabilities': (longTermLiabilities as LongTermLiabilitiesModel).toJson(),
      'total': total,
    };
  }
}

class CurrentLiabilitiesModel extends CurrentLiabilities {
  const CurrentLiabilitiesModel({
    required super.accountsPayable,
    required super.accruedExpenses,
    required super.shortTermDebt,
    required super.taxLiabilities,
    required super.total,
  });

  factory CurrentLiabilitiesModel.fromJson(Map<String, dynamic> json) {
    return CurrentLiabilitiesModel(
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

class LongTermLiabilitiesModel extends LongTermLiabilities {
  const LongTermLiabilitiesModel({
    required super.longTermDebt,
    required super.deferredTax,
    required super.other,
    required super.total,
  });

  factory LongTermLiabilitiesModel.fromJson(Map<String, dynamic> json) {
    return LongTermLiabilitiesModel(
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

class BalanceSheetEquityModel extends BalanceSheetEquity {
  const BalanceSheetEquityModel({
    required super.retainedEarnings,
    required super.unrealizedGainsLosses,
    required super.total,
  });

  factory BalanceSheetEquityModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetEquityModel(
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

class BalanceSheetTotalsModel extends BalanceSheetTotals {
  const BalanceSheetTotalsModel({
    required super.totalAssets,
    required super.totalLiabilities,
    required super.totalEquity,
    required super.balanceCheck,
  });

  factory BalanceSheetTotalsModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetTotalsModel(
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

class BalanceSheetSummaryModel extends BalanceSheetSummary {
  const BalanceSheetSummaryModel({
    required super.financialPosition,
    required super.debtToEquityRatio,
    required super.assetComposition,
    required super.liquidityRatio,
    required super.netWorth,
  });

  factory BalanceSheetSummaryModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetSummaryModel(
      financialPosition: json['financial_position']?.toString() ?? 'Unknown',
      debtToEquityRatio: json['debt_to_equity_ratio']?.toString() ?? 'Undefined',
      assetComposition: AssetCompositionModel.fromJson(_safeConvertMap(json['asset_composition'])),
      liquidityRatio: json['liquidity_ratio']?.toString() ?? 'Unlimited',
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'financial_position': financialPosition,
      'debt_to_equity_ratio': debtToEquityRatio,
      'asset_composition': (assetComposition as AssetCompositionModel).toJson(),
      'liquidity_ratio': liquidityRatio,
      'net_worth': netWorth,
    };
  }
}

class AssetCompositionModel extends AssetComposition {
  const AssetCompositionModel({
    required super.cryptoPercentage,
    required super.cashPercentage,
  });

  factory AssetCompositionModel.fromJson(Map<String, dynamic> json) {
    return AssetCompositionModel(
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

class BalanceSheetMetadataModel extends BalanceSheetMetadata {
  const BalanceSheetMetadataModel({
    required super.transactionCount,
    required super.dateRange,
  });

  factory BalanceSheetMetadataModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetMetadataModel(
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
      dateRange: DateRangeModel.fromJson(_safeConvertMap(json['date_range'])),
    );
  }

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'date_range': (dateRange as DateRangeModel).toJson(),
    };
  }
}

class DateRangeModel extends DateRange {
  const DateRangeModel({
    required super.earliestTransaction,
    required super.latestTransaction,
  });

  factory DateRangeModel.fromJson(Map<String, dynamic> json) {
    return DateRangeModel(
      earliestTransaction: _safeParseDateTime(json['earliest_transaction']),
      latestTransaction: _safeParseDateTime(json['latest_transaction']),
    );
  }

  static DateTime _safeParseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'earliest_transaction': earliestTransaction.toIso8601String(),
      'latest_transaction': latestTransaction.toIso8601String(),
    };
  }
}
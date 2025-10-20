class InvestmentReport {
  final String id;
  final String investmentReportId;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String currency;
  final PortfolioPerformance portfolioPerformance;
  final AssetAllocation assetAllocation;
  final RoiAnalysis roiAnalysis;
  final RiskMetrics riskMetrics;
  final String llmAnalysis;
  final InvestmentSummary summary;
  final InvestmentMetadata metadata;

  const InvestmentReport({
    required this.id,
    required this.investmentReportId,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.currency,
    required this.portfolioPerformance,
    required this.assetAllocation,
    required this.roiAnalysis,
    required this.riskMetrics,
    required this.llmAnalysis,
    required this.summary,
    required this.metadata,
  });
}

class PortfolioPerformance {
  final double totalPortfolioValue;
  final double periodGains;
  final double periodLosses;
  final double netPerformance;
  final double performancePercentage;
  final String? bestPerformingAsset;
  final String? worstPerformingAsset;
  final Map<String, Map<String, double>> byCryptocurrency;
  final TimeframeData byTimeframe;

  const PortfolioPerformance({
    required this.totalPortfolioValue,
    required this.periodGains,
    required this.periodLosses,
    required this.netPerformance,
    required this.performancePercentage,
    this.bestPerformingAsset,
    this.worstPerformingAsset,
    required this.byCryptocurrency,
    required this.byTimeframe,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_portfolio_value': totalPortfolioValue,
      'period_gains': periodGains,
      'period_losses': periodLosses,
      'net_performance': netPerformance,
      'performance_percentage': performancePercentage,
      'best_performing_asset': bestPerformingAsset,
      'worst_performing_asset': worstPerformingAsset,
      'by_cryptocurrency': byCryptocurrency,
      'by_timeframe': byTimeframe.toJson(),
    };
  }
}

class AssetAllocation {
  final double totalValue;
  final Map<String, double> byCryptocurrency;
  final Map<String, double> allocationPercentages;
  final double diversificationScore;

  const AssetAllocation({
    required this.totalValue,
    required this.byCryptocurrency,
    required this.allocationPercentages,
    required this.diversificationScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_value': totalValue,
      'by_cryptocurrency': byCryptocurrency,
      'allocation_percentages': allocationPercentages,
      'diversification_score': diversificationScore,
    };
  }
}

class RoiAnalysis {
  final double totalInvested;
  final double currentValue;
  final double totalReturns;
  final double roiPercentage;
  final double annualizedRoi;
  final Map<String, Map<String, double>> byCryptocurrency;
  final TimeframeReturns byTimeframe;

  const RoiAnalysis({
    required this.totalInvested,
    required this.currentValue,
    required this.totalReturns,
    required this.roiPercentage,
    required this.annualizedRoi,
    required this.byCryptocurrency,
    required this.byTimeframe,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_invested': totalInvested,
      'current_value': currentValue,
      'total_returns': totalReturns,
      'roi_percentage': roiPercentage,
      'annualized_roi': annualizedRoi,
      'by_cryptocurrency': byCryptocurrency,
      'by_timeframe': byTimeframe.toJson(),
    };
  }
}

class RiskMetrics {
  final double volatilityScore;
  final double concentrationRisk;
  final double liquidityRisk;
  final int transactionFrequency;
  final String riskLevel;

  const RiskMetrics({
    required this.volatilityScore,
    required this.concentrationRisk,
    required this.liquidityRisk,
    required this.transactionFrequency,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'volatility_score': volatilityScore,
      'concentration_risk': concentrationRisk,
      'liquidity_risk': liquidityRisk,
      'transaction_frequency': transactionFrequency,
      'risk_level': riskLevel,
    };
  }
}

class InvestmentSummary {
  final String performanceSummary;
  final String riskAssessment;
  final String? topPerformer;
  final String? concernAreas;
  final String investmentStatus;
  final List<String> recommendations;

  const InvestmentSummary({
    required this.performanceSummary,
    required this.riskAssessment,
    this.topPerformer,
    this.concernAreas,
    required this.investmentStatus,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'performance_summary': performanceSummary,
      'risk_assessment': riskAssessment,
      'top_performer': topPerformer,
      'concern_areas': concernAreas,
      'investment_status': investmentStatus,
      'recommendations': recommendations,
    };
  }
}

class InvestmentMetadata {
  final int transactionCount;
  final int historicalTransactionCount;
  final int periodLengthDays;

  const InvestmentMetadata({
    required this.transactionCount,
    required this.historicalTransactionCount,
    required this.periodLengthDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'historical_transaction_count': historicalTransactionCount,
      'period_length_days': periodLengthDays,
    };
  }
}

class TimeframeData {
  final Map<String, double> daily;
  final Map<String, double> weekly;
  final Map<String, double> monthly;

  const TimeframeData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily': daily,
      'weekly': weekly,
      'monthly': monthly,
    };
  }
}

class TimeframeReturns {
  final double dailyReturn;
  final double weeklyReturn;
  final double monthlyReturn;

  const TimeframeReturns({
    required this.dailyReturn,
    required this.weeklyReturn,
    required this.monthlyReturn,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_return': dailyReturn,
      'weekly_return': weeklyReturn,
      'monthly_return': monthlyReturn,
    };
  }
}

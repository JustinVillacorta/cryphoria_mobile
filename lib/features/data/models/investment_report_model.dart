import '../../domain/entities/investment_report.dart';

class InvestmentReportModel extends InvestmentReport {
  const InvestmentReportModel({
    required super.id,
    required super.investmentReportId,
    required super.userId,
    required super.periodStart,
    required super.periodEnd,
    required super.generatedAt,
    required super.currency,
    required super.portfolioPerformance,
    required super.assetAllocation,
    required super.roiAnalysis,
    required super.riskMetrics,
    required super.llmAnalysis,
    required super.summary,
    required super.metadata,
  });

  factory InvestmentReportModel.fromJson(Map<String, dynamic> json) {
    return InvestmentReportModel(
      id: json['_id'] ?? '',
      investmentReportId: json['investment_report_id'] ?? '',
      userId: json['user_id'] ?? '',
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      generatedAt: DateTime.parse(json['generated_at']),
      currency: json['currency'] ?? 'USD',
      portfolioPerformance: PortfolioPerformanceModel.fromJson(json['portfolio_performance'] ?? {}),
      assetAllocation: AssetAllocationModel.fromJson(json['asset_allocation'] ?? {}),
      roiAnalysis: RoiAnalysisModel.fromJson(json['roi_analysis'] ?? {}),
      riskMetrics: RiskMetricsModel.fromJson(json['risk_metrics'] ?? {}),
      llmAnalysis: json['llm_analysis'] ?? '',
      summary: InvestmentSummaryModel.fromJson(json['summary'] ?? {}),
      metadata: InvestmentMetadataModel.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'investment_report_id': investmentReportId,
      'user_id': userId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'currency': currency,
      'portfolio_performance': portfolioPerformance.toJson(),
      'asset_allocation': assetAllocation.toJson(),
      'roi_analysis': roiAnalysis.toJson(),
      'risk_metrics': riskMetrics.toJson(),
      'llm_analysis': llmAnalysis,
      'summary': summary.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class PortfolioPerformanceModel extends PortfolioPerformance {
  const PortfolioPerformanceModel({
    required super.totalPortfolioValue,
    required super.periodGains,
    required super.periodLosses,
    required super.netPerformance,
    required super.performancePercentage,
    super.bestPerformingAsset,
    super.worstPerformingAsset,
    required super.byCryptocurrency,
    required super.byTimeframe,
  });

  factory PortfolioPerformanceModel.fromJson(Map<String, dynamic> json) {
    return PortfolioPerformanceModel(
      totalPortfolioValue: (json['total_portfolio_value'] ?? 0).toDouble(),
      periodGains: (json['period_gains'] ?? 0).toDouble(),
      periodLosses: (json['period_losses'] ?? 0).toDouble(),
      netPerformance: (json['net_performance'] ?? 0).toDouble(),
      performancePercentage: (json['performance_percentage'] ?? 0).toDouble(),
      bestPerformingAsset: json['best_performing_asset'],
      worstPerformingAsset: json['worst_performing_asset'],
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
      byTimeframe: TimeframeDataModel.fromJson(json['by_timeframe'] ?? {}),
    );
  }
}

class AssetAllocationModel extends AssetAllocation {
  const AssetAllocationModel({
    required super.totalValue,
    required super.byCryptocurrency,
    required super.allocationPercentages,
    required super.diversificationScore,
  });

  factory AssetAllocationModel.fromJson(Map<String, dynamic> json) {
    return AssetAllocationModel(
      totalValue: (json['total_value'] ?? 0).toDouble(),
      byCryptocurrency: Map<String, double>.from(
        (json['by_cryptocurrency'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
      allocationPercentages: Map<String, double>.from(
        (json['allocation_percentages'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
      diversificationScore: (json['diversification_score'] ?? 0).toDouble(),
    );
  }
}

class RoiAnalysisModel extends RoiAnalysis {
  const RoiAnalysisModel({
    required super.totalInvested,
    required super.currentValue,
    required super.totalReturns,
    required super.roiPercentage,
    required super.annualizedRoi,
    required super.byCryptocurrency,
    required super.byTimeframe,
  });

  factory RoiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return RoiAnalysisModel(
      totalInvested: (json['total_invested'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      totalReturns: (json['total_returns'] ?? 0).toDouble(),
      roiPercentage: (json['roi_percentage'] ?? 0).toDouble(),
      annualizedRoi: (json['annualized_roi'] ?? 0).toDouble(),
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
      byTimeframe: TimeframeReturnsModel.fromJson(json['by_timeframe'] ?? {}),
    );
  }
}

class RiskMetricsModel extends RiskMetrics {
  const RiskMetricsModel({
    required super.volatilityScore,
    required super.concentrationRisk,
    required super.liquidityRisk,
    required super.transactionFrequency,
    required super.riskLevel,
  });

  factory RiskMetricsModel.fromJson(Map<String, dynamic> json) {
    return RiskMetricsModel(
      volatilityScore: (json['volatility_score'] ?? 0).toDouble(),
      concentrationRisk: (json['concentration_risk'] ?? 0).toDouble(),
      liquidityRisk: (json['liquidity_risk'] ?? 0).toDouble(),
      transactionFrequency: json['transaction_frequency'] ?? 0,
      riskLevel: json['risk_level'] ?? 'UNKNOWN',
    );
  }
}

class InvestmentSummaryModel extends InvestmentSummary {
  const InvestmentSummaryModel({
    required super.performanceSummary,
    required super.riskAssessment,
    super.topPerformer,
    super.concernAreas,
    required super.investmentStatus,
    required super.recommendations,
  });

  factory InvestmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvestmentSummaryModel(
      performanceSummary: json['performance_summary'] ?? '',
      riskAssessment: json['risk_assessment'] ?? '',
      topPerformer: json['top_performer'],
      concernAreas: json['concern_areas'],
      investmentStatus: json['investment_status'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class InvestmentMetadataModel extends InvestmentMetadata {
  const InvestmentMetadataModel({
    required super.transactionCount,
    required super.historicalTransactionCount,
    required super.periodLengthDays,
  });

  factory InvestmentMetadataModel.fromJson(Map<String, dynamic> json) {
    return InvestmentMetadataModel(
      transactionCount: json['transaction_count'] ?? 0,
      historicalTransactionCount: json['historical_transaction_count'] ?? 0,
      periodLengthDays: json['period_length_days'] ?? 0,
    );
  }
}

class TimeframeDataModel extends TimeframeData {
  const TimeframeDataModel({
    required super.daily,
    required super.weekly,
    required super.monthly,
  });

  factory TimeframeDataModel.fromJson(Map<String, dynamic> json) {
    return TimeframeDataModel(
      daily: Map<String, double>.from(
        (json['daily'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
      weekly: Map<String, double>.from(
        (json['weekly'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
      monthly: Map<String, double>.from(
        (json['monthly'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0).toDouble()),
        ),
      ),
    );
  }
}

class TimeframeReturnsModel extends TimeframeReturns {
  const TimeframeReturnsModel({
    required super.dailyReturn,
    required super.weeklyReturn,
    required super.monthlyReturn,
  });

  factory TimeframeReturnsModel.fromJson(Map<String, dynamic> json) {
    return TimeframeReturnsModel(
      dailyReturn: (json['daily_return'] ?? 0).toDouble(),
      weeklyReturn: (json['weekly_return'] ?? 0).toDouble(),
      monthlyReturn: (json['monthly_return'] ?? 0).toDouble(),
    );
  }
}

class InvestmentReportsResponseModel {
  final bool success;
  final List<InvestmentReportModel> investmentReports;
  final String? message;

  const InvestmentReportsResponseModel({
    required this.success,
    required this.investmentReports,
    this.message,
  });

  factory InvestmentReportsResponseModel.fromJson(Map<String, dynamic> json) {
    return InvestmentReportsResponseModel(
      success: json['success'] ?? false,
      investmentReports: (json['investment_reports'] as List?)
              ?.map((item) => InvestmentReportModel.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

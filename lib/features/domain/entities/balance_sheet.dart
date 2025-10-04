// lib/features/domain/entities/balance_sheet.dart

class BalanceSheet {
  final String id;
  final String reportType;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final BalanceSheetSummary summary;
  final List<Asset> assets;
  final List<Liability> liabilities;
  final List<Equity> equity;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? generatedAt;

  const BalanceSheet({
    required this.id,
    required this.reportType,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    required this.summary,
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.metadata,
    required this.createdAt,
    this.generatedAt,
  });

  factory BalanceSheet.fromJson(Map<String, dynamic> json) {
    return BalanceSheet(
      id: json['id'] as String,
      reportType: json['report_type'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currency: json['currency'] as String? ?? 'USD',
      summary: BalanceSheetSummary.fromJson(json['summary'] as Map<String, dynamic>),
      assets: (json['assets'] as List<dynamic>)
          .map((a) => Asset.fromJson(a as Map<String, dynamic>))
          .toList(),
      liabilities: (json['liabilities'] as List<dynamic>)
          .map((l) => Liability.fromJson(l as Map<String, dynamic>))
          .toList(),
      equity: (json['equity'] as List<dynamic>)
          .map((e) => Equity.fromJson(e as Map<String, dynamic>))
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
      'assets': assets.map((a) => a.toJson()).toList(),
      'liabilities': liabilities.map((l) => l.toJson()).toList(),
      'equity': equity.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}

class BalanceSheetSummary {
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final double workingCapital;
  final double currentRatio;
  final double debtToEquityRatio;
  final Map<String, double> assetBreakdown;
  final Map<String, double> liabilityBreakdown;
  final Map<String, double> equityBreakdown;

  const BalanceSheetSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.workingCapital,
    required this.currentRatio,
    required this.debtToEquityRatio,
    required this.assetBreakdown,
    required this.liabilityBreakdown,
    required this.equityBreakdown,
  });

  factory BalanceSheetSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSheetSummary(
      totalAssets: (json['total_assets'] as num).toDouble(),
      totalLiabilities: (json['total_liabilities'] as num).toDouble(),
      totalEquity: (json['total_equity'] as num).toDouble(),
      workingCapital: (json['working_capital'] as num).toDouble(),
      currentRatio: (json['current_ratio'] as num).toDouble(),
      debtToEquityRatio: (json['debt_to_equity_ratio'] as num).toDouble(),
      assetBreakdown: Map<String, double>.from(json['asset_breakdown'] as Map<String, dynamic>),
      liabilityBreakdown: Map<String, double>.from(json['liability_breakdown'] as Map<String, dynamic>),
      equityBreakdown: Map<String, double>.from(json['equity_breakdown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'total_equity': totalEquity,
      'working_capital': workingCapital,
      'current_ratio': currentRatio,
      'debt_to_equity_ratio': debtToEquityRatio,
      'asset_breakdown': assetBreakdown,
      'liability_breakdown': liabilityBreakdown,
      'equity_breakdown': equityBreakdown,
    };
  }
}

class Asset {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final double amount;
  final String description;
  final bool isCurrent;
  final Map<String, dynamic> metadata;

  const Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.description,
    required this.isCurrent,
    required this.metadata,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'description': description,
      'is_current': isCurrent,
      'metadata': metadata,
    };
  }
}

class Liability {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final double amount;
  final String description;
  final bool isCurrent;
  final Map<String, dynamic> metadata;

  const Liability({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.description,
    required this.isCurrent,
    required this.metadata,
  });

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'description': description,
      'is_current': isCurrent,
      'metadata': metadata,
    };
  }
}

class Equity {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final double amount;
  final String description;
  final Map<String, dynamic> metadata;

  const Equity({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.description,
    required this.metadata,
  });

  factory Equity.fromJson(Map<String, dynamic> json) {
    return Equity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'description': description,
      'metadata': metadata,
    };
  }
}

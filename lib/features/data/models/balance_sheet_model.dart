// lib/features/data/models/balance_sheet_model.dart

import '../../domain/entities/balance_sheet.dart';

class BalanceSheetModel extends BalanceSheet {
  const BalanceSheetModel({
    required super.id,
    required super.reportType,
    required super.reportDate,
    required super.periodStart,
    required super.periodEnd,
    required super.currency,
    required super.summary,
    required super.assets,
    required super.liabilities,
    required super.equity,
    required super.metadata,
    required super.createdAt,
    super.generatedAt,
  });

  factory BalanceSheetModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetModel(
      id: json['id']?.toString() ?? '',
      reportType: json['report_type']?.toString() ?? 'Balance Sheet',
      reportDate: _safeParseDateTime(json['report_date']),
      periodStart: _safeParseDateTime(json['period_start']),
      periodEnd: _safeParseDateTime(json['period_end']),
      currency: json['currency']?.toString() ?? 'USD',
      summary: BalanceSheetSummaryModel.fromJson(_safeConvertMap(json['summary'])),
      assets: _safeConvertAssetList(json['assets']),
      liabilities: _safeConvertLiabilityList(json['liabilities']),
      equity: _safeConvertEquityList(json['equity']),
      metadata: _safeConvertMap(json['metadata']),
      createdAt: _safeParseDateTime(json['created_at']),
      generatedAt: json['generated_at'] != null 
          ? _safeParseDateTime(json['generated_at']) 
          : null,
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
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<AssetModel> _safeConvertAssetList(dynamic value) {
    if (value == null) return <AssetModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return AssetModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return AssetModel(
            id: 'unknown',
            name: 'Unknown Asset',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            description: 'Error loading asset',
            isCurrent: false,
            metadata: {},
          );
        }
      }).toList();
    }
    return <AssetModel>[];
  }

  static List<LiabilityModel> _safeConvertLiabilityList(dynamic value) {
    if (value == null) return <LiabilityModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return LiabilityModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return LiabilityModel(
            id: 'unknown',
            name: 'Unknown Liability',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            description: 'Error loading liability',
            isCurrent: false,
            metadata: {},
          );
        }
      }).toList();
    }
    return <LiabilityModel>[];
  }

  static List<EquityModel> _safeConvertEquityList(dynamic value) {
    if (value == null) return <EquityModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return EquityModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return EquityModel(
            id: 'unknown',
            name: 'Unknown Equity',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            description: 'Error loading equity',
            metadata: {},
          );
        }
      }).toList();
    }
    return <EquityModel>[];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'report_date': reportDate.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'currency': currency,
      'summary': (summary as BalanceSheetSummaryModel).toJson(),
      'assets': assets.map((a) => (a as AssetModel).toJson()).toList(),
      'liabilities': liabilities.map((l) => (l as LiabilityModel).toJson()).toList(),
      'equity': equity.map((e) => (e as EquityModel).toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}

class BalanceSheetSummaryModel extends BalanceSheetSummary {
  const BalanceSheetSummaryModel({
    required super.totalAssets,
    required super.totalLiabilities,
    required super.totalEquity,
    required super.workingCapital,
    required super.currentRatio,
    required super.debtToEquityRatio,
    required super.assetBreakdown,
    required super.liabilityBreakdown,
    required super.equityBreakdown,
  });

  factory BalanceSheetSummaryModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetSummaryModel(
      totalAssets: _safeToDouble(json['total_assets']),
      totalLiabilities: _safeToDouble(json['total_liabilities']),
      totalEquity: _safeToDouble(json['total_equity']),
      workingCapital: _safeToDouble(json['working_capital']),
      currentRatio: _safeToDouble(json['current_ratio']),
      debtToEquityRatio: _safeToDouble(json['debt_to_equity_ratio']),
      assetBreakdown: _safeConvertToDoubleMap(json['asset_breakdown']),
      liabilityBreakdown: _safeConvertToDoubleMap(json['liability_breakdown']),
      equityBreakdown: _safeConvertToDoubleMap(json['equity_breakdown']),
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.toLowerCase() == 'undefined' || value.toLowerCase() == 'null') {
        return 0.0;
      }
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static Map<String, double> _safeConvertToDoubleMap(dynamic value) {
    if (value == null) return <String, double>{};
    if (value is Map<String, dynamic>) {
      final Map<String, double> result = {};
      value.forEach((key, val) {
        result[key] = _safeToDouble(val);
      });
      return result;
    }
    return <String, double>{};
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

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.name,
    required super.category,
    required super.subCategory,
    required super.amount,
    required super.description,
    required super.isCurrent,
    required super.metadata,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
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

class LiabilityModel extends Liability {
  const LiabilityModel({
    required super.id,
    required super.name,
    required super.category,
    required super.subCategory,
    required super.amount,
    required super.description,
    required super.isCurrent,
    required super.metadata,
  });

  factory LiabilityModel.fromJson(Map<String, dynamic> json) {
    return LiabilityModel(
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

class EquityModel extends Equity {
  const EquityModel({
    required super.id,
    required super.name,
    required super.category,
    required super.subCategory,
    required super.amount,
    required super.description,
    required super.metadata,
  });

  factory EquityModel.fromJson(Map<String, dynamic> json) {
    return EquityModel(
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

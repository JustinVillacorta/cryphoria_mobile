// lib/features/data/models/cash_flow_model.dart

import '../../domain/entities/cash_flow.dart';

class CashFlowModel extends CashFlow {
  const CashFlowModel({
    required super.id,
    required super.reportType,
    required super.reportDate,
    required super.periodStart,
    required super.periodEnd,
    required super.currency,
    required super.summary,
    required super.operatingActivities,
    required super.investingActivities,
    required super.financingActivities,
    required super.metadata,
    required super.createdAt,
    super.generatedAt,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      id: json['id']?.toString() ?? '',
      reportType: json['report_type']?.toString() ?? 'Cash Flow Statement',
      reportDate: _safeParseDateTime(json['report_date']),
      periodStart: _safeParseDateTime(json['period_start']),
      periodEnd: _safeParseDateTime(json['period_end']),
      currency: json['currency']?.toString() ?? 'USD',
      summary: CashFlowSummaryModel.fromJson(_safeConvertMap(json['summary'])),
      operatingActivities: _safeConvertOperatingActivitiesList(json['operating_activities']),
      investingActivities: _safeConvertInvestingActivitiesList(json['investing_activities']),
      financingActivities: _safeConvertFinancingActivitiesList(json['financing_activities']),
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

  static List<OperatingActivityModel> _safeConvertOperatingActivitiesList(dynamic value) {
    if (value == null) return <OperatingActivityModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return OperatingActivityModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return OperatingActivityModel(
            id: 'unknown',
            description: 'Error loading activity',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            transactionDate: DateTime.now(),
            currency: 'USD',
            metadata: {},
          );
        }
      }).toList();
    }
    return <OperatingActivityModel>[];
  }

  static List<InvestingActivityModel> _safeConvertInvestingActivitiesList(dynamic value) {
    if (value == null) return <InvestingActivityModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return InvestingActivityModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return InvestingActivityModel(
            id: 'unknown',
            description: 'Error loading activity',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            transactionDate: DateTime.now(),
            currency: 'USD',
            metadata: {},
          );
        }
      }).toList();
    }
    return <InvestingActivityModel>[];
  }

  static List<FinancingActivityModel> _safeConvertFinancingActivitiesList(dynamic value) {
    if (value == null) return <FinancingActivityModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return FinancingActivityModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return FinancingActivityModel(
            id: 'unknown',
            description: 'Error loading activity',
            amount: 0.0,
            category: 'Unknown',
            subCategory: 'Unknown',
            transactionDate: DateTime.now(),
            currency: 'USD',
            metadata: {},
          );
        }
      }).toList();
    }
    return <FinancingActivityModel>[];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'report_date': reportDate.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'currency': currency,
      'summary': (summary as CashFlowSummaryModel).toJson(),
      'operating_activities': operatingActivities.map((o) => (o as OperatingActivityModel).toJson()).toList(),
      'investing_activities': investingActivities.map((i) => (i as InvestingActivityModel).toJson()).toList(),
      'financing_activities': financingActivities.map((f) => (f as FinancingActivityModel).toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}

class CashFlowSummaryModel extends CashFlowSummary {
  const CashFlowSummaryModel({
    required super.netCashFromOperations,
    required super.netCashFromInvesting,
    required super.netCashFromFinancing,
    required super.netChangeInCash,
    required super.beginningCash,
    required super.endingCash,
    required super.operatingBreakdown,
    required super.investingBreakdown,
    required super.financingBreakdown,
  });

  factory CashFlowSummaryModel.fromJson(Map<String, dynamic> json) {
    return CashFlowSummaryModel(
      netCashFromOperations: _safeToDouble(json['net_cash_from_operations']),
      netCashFromInvesting: _safeToDouble(json['net_cash_from_investing']),
      netCashFromFinancing: _safeToDouble(json['net_cash_from_financing']),
      netChangeInCash: _safeToDouble(json['net_change_in_cash']),
      beginningCash: _safeToDouble(json['beginning_cash']),
      endingCash: _safeToDouble(json['ending_cash']),
      operatingBreakdown: _safeConvertToDoubleMap(json['operating_breakdown']),
      investingBreakdown: _safeConvertToDoubleMap(json['investing_breakdown']),
      financingBreakdown: _safeConvertToDoubleMap(json['financing_breakdown']),
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
      'net_cash_from_operations': netCashFromOperations,
      'net_cash_from_investing': netCashFromInvesting,
      'net_cash_from_financing': netCashFromFinancing,
      'net_change_in_cash': netChangeInCash,
      'beginning_cash': beginningCash,
      'ending_cash': endingCash,
      'operating_breakdown': operatingBreakdown,
      'investing_breakdown': investingBreakdown,
      'financing_breakdown': financingBreakdown,
    };
  }
}

class OperatingActivityModel extends OperatingActivity {
  const OperatingActivityModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.category,
    required super.subCategory,
    required super.transactionDate,
    required super.currency,
    super.reference,
    required super.metadata,
  });

  factory OperatingActivityModel.fromJson(Map<String, dynamic> json) {
    return OperatingActivityModel(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _safeToDouble(json['amount']),
      category: json['category']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      transactionDate: _safeParseDateTime(json['transaction_date']),
      currency: json['currency']?.toString() ?? 'USD',
      reference: json['reference']?.toString(),
      metadata: _safeConvertMap(json['metadata']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

class InvestingActivityModel extends InvestingActivity {
  const InvestingActivityModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.category,
    required super.subCategory,
    required super.transactionDate,
    required super.currency,
    super.reference,
    required super.metadata,
  });

  factory InvestingActivityModel.fromJson(Map<String, dynamic> json) {
    return InvestingActivityModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      currency: json['currency'] as String? ?? 'USD',
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

class FinancingActivityModel extends FinancingActivity {
  const FinancingActivityModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.category,
    required super.subCategory,
    required super.transactionDate,
    required super.currency,
    super.reference,
    required super.metadata,
  });

  factory FinancingActivityModel.fromJson(Map<String, dynamic> json) {
    return FinancingActivityModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      currency: json['currency'] as String? ?? 'USD',
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'sub_category': subCategory,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'reference': reference,
      'metadata': metadata,
    };
  }
}

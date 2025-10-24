// lib/features/data/models/tax_report_model.dart

import '../../domain/entities/tax_report.dart';

class TaxReportModel extends TaxReport {
  const TaxReportModel({
    required super.id,
    required super.reportType,
    required super.reportDate,
    required super.periodStart,
    required super.periodEnd,
    required super.currency,
    required super.summary,
    required super.categories,
    required super.transactions,
    required super.metadata,
    required super.createdAt,
    super.generatedAt,
    super.llmAnalysis,
    super.reportId,
    super.status,
    super.totalGains,
    super.totalLosses,
    super.netPnl,
    super.totalIncome,
    super.totalExpenses,
    super.taxDeductionSummary,
  });

  factory TaxReportModel.fromJson(Map<String, dynamic> json) {
    return TaxReportModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      reportType: json['report_type']?.toString() ?? 'Tax Report',
      reportDate: _safeParseDateTime(json['generated_at'] ?? json['report_date']),
      periodStart: _safeParseDateTime(json['start_date'] ?? json['period_start']),
      periodEnd: _safeParseDateTime(json['end_date'] ?? json['period_end']),
      currency: json['currency']?.toString() ?? 'USD',
      summary: _createDefaultSummary(json),
      categories: _safeConvertTaxCategoriesList(json['categories']),
      transactions: _safeConvertTaxTransactionsList(json['transactions']),
      metadata: _safeConvertMap(json['metadata']),
      createdAt: _safeParseDateTime(json['generated_at'] ?? json['created_at']),
      generatedAt: json['generated_at'] != null 
          ? _safeParseDateTime(json['generated_at']) 
          : null,
      llmAnalysis: json['llm_analysis']?.toString(),
      reportId: json['report_id']?.toString(),
      status: json['status']?.toString(),
      totalGains: json['total_gains'] != null ? _safeToDouble(json['total_gains']) : null,
      totalLosses: json['total_losses'] != null ? _safeToDouble(json['total_losses']) : null,
      netPnl: json['net_pnl'] != null ? _safeToDouble(json['net_pnl']) : null,
      totalIncome: json['total_income'] != null ? _safeToDouble(json['total_income']) : null,
      totalExpenses: json['total_expenses'] != null ? _safeToDouble(json['total_expenses']) : null,
      taxDeductionSummary: _safeConvertMap(json['tax_deduction_summary']),
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

  static Map<String, dynamic> _safeConvertMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static TaxSummaryModel _createDefaultSummary(Map<String, dynamic> json) {
    // Extract data from top-level fields
    final totalIncome = _safeToDouble(json['total_income']);
    
    // Extract data from metadata.calculations if available
    final metadata = _safeConvertMap(json['metadata']);
    final calculations = _safeConvertMap(metadata['calculations']);
    final metadataTotalIncome = _safeToDouble(calculations['total_income']);
    
    // Use metadata values if top-level values are 0 or null
    final finalTotalIncome = totalIncome > 0 ? totalIncome : metadataTotalIncome;
    
    // Extract tax deduction data
    final taxDeductionSummary = _safeConvertMap(json['tax_deduction_summary']);
    final periodSummary = _safeConvertMap(taxDeductionSummary['period_summary']);
    final totalDeductionsMap = _safeConvertMap(periodSummary['total_deductions']);
    
    // Calculate total deductions from all deduction types
    double totalDeductions = 0.0;
    if (totalDeductionsMap.isNotEmpty) {
      totalDeductions = totalDeductionsMap.values
          .where((value) => value != null)
          .map((value) => _safeToDouble(value))
          .fold(0.0, (sum, value) => sum + value);
    }
    
    // Extract total tax amount
    final totalTaxAmount = _safeToDouble(periodSummary['total_tax_amount']);
    
    // Calculate taxable income
    final taxableIncome = finalTotalIncome - totalDeductions;
    
    return TaxSummaryModel(
      totalIncome: finalTotalIncome,
      totalDeductions: totalDeductions,
      taxableIncome: taxableIncome,
      totalTaxOwed: totalTaxAmount,
      totalTaxPaid: 0.0, // Default value - not provided in API
      netTaxOwed: totalTaxAmount, // Same as totalTaxOwed for now
      taxBreakdown: <String, double>{}, // Could be populated from tax_deduction_summary
      incomeBreakdown: <String, double>{}, // Could be populated from metadata.calculations
      deductionBreakdown: totalDeductionsMap.map((key, value) => MapEntry(key, _safeToDouble(value))),
    );
  }

  static List<TaxCategoryModel> _safeConvertTaxCategoriesList(dynamic value) {
    if (value == null) return <TaxCategoryModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return TaxCategoryModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return TaxCategoryModel(
            id: 'unknown',
            name: 'Unknown Category',
            description: 'Error loading category',
            amount: 0.0,
            type: 'unknown',
            subCategories: [],
          );
        }
      }).toList();
    }
    return <TaxCategoryModel>[];
  }

  static List<TaxTransactionModel> _safeConvertTaxTransactionsList(dynamic value) {
    if (value == null) return <TaxTransactionModel>[];
    if (value is List) {
      return value.map((item) {
        try {
          return TaxTransactionModel.fromJson(_safeConvertMap(item));
        } catch (e) {
          return TaxTransactionModel(
            id: 'unknown',
            description: 'Error loading transaction',
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
    return <TaxTransactionModel>[];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'report_date': reportDate.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'currency': currency,
      'summary': (summary as TaxSummaryModel).toJson(),
      'categories': categories.map((c) => (c as TaxCategoryModel).toJson()).toList(),
      'transactions': transactions.map((t) => (t as TaxTransactionModel).toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
      'llm_analysis': llmAnalysis,
      'report_id': reportId,
      'status': status,
      'total_gains': totalGains,
      'total_losses': totalLosses,
      'net_pnl': netPnl,
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'tax_deduction_summary': taxDeductionSummary,
    };
  }
}

class TaxSummaryModel extends TaxSummary {
  const TaxSummaryModel({
    required super.totalIncome,
    required super.totalDeductions,
    required super.taxableIncome,
    required super.totalTaxOwed,
    required super.totalTaxPaid,
    required super.netTaxOwed,
    required super.taxBreakdown,
    required super.incomeBreakdown,
    required super.deductionBreakdown,
  });

  factory TaxSummaryModel.fromJson(Map<String, dynamic> json) {
    return TaxSummaryModel(
      totalIncome: _safeToDouble(json['total_income']),
      totalDeductions: _safeToDouble(json['total_deductions']),
      taxableIncome: _safeToDouble(json['taxable_income']),
      totalTaxOwed: _safeToDouble(json['total_tax_owed']),
      totalTaxPaid: _safeToDouble(json['total_tax_paid']),
      netTaxOwed: _safeToDouble(json['net_tax_owed']),
      taxBreakdown: _safeConvertToDoubleMap(json['tax_breakdown']),
      incomeBreakdown: _safeConvertToDoubleMap(json['income_breakdown']),
      deductionBreakdown: _safeConvertToDoubleMap(json['deduction_breakdown']),
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
    if (value is Map) {
      final Map<String, double> result = {};
      value.forEach((key, val) {
        final stringKey = key?.toString() ?? 'unknown';
        result[stringKey] = _safeToDouble(val);
      });
      return result;
    }
    return <String, double>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_deductions': totalDeductions,
      'taxable_income': taxableIncome,
      'total_tax_owed': totalTaxOwed,
      'total_tax_paid': totalTaxPaid,
      'net_tax_owed': netTaxOwed,
      'tax_breakdown': taxBreakdown,
      'income_breakdown': incomeBreakdown,
      'deduction_breakdown': deductionBreakdown,
    };
  }
}

class TaxCategoryModel extends TaxCategory {
  const TaxCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.amount,
    required super.type,
    required super.subCategories,
  });

  factory TaxCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaxCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      subCategories: (json['sub_categories'] as List<dynamic>? ?? [])
          .map((s) => TaxSubCategoryModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'type': type,
      'sub_categories': subCategories.map((s) => (s as TaxSubCategoryModel).toJson()).toList(),
    };
  }
}

class TaxSubCategoryModel extends TaxSubCategory {
  const TaxSubCategoryModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.description,
  });

  factory TaxSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaxSubCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'description': description,
    };
  }
}

class TaxTransactionModel extends TaxTransaction {
  const TaxTransactionModel({
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

  factory TaxTransactionModel.fromJson(Map<String, dynamic> json) {
    return TaxTransactionModel(
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

// lib/features/domain/entities/tax_report.dart

class TaxReport {
  final String id;
  final String reportType;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final TaxSummary summary;
  final List<TaxCategory> categories;
  final List<TaxTransaction> transactions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? generatedAt;
  final String? llmAnalysis;
  final String? reportId;
  final String? status;
  final double? totalGains;
  final double? totalLosses;
  final double? netPnl;
  final double? totalIncome;
  final double? totalExpenses;
  final Map<String, dynamic>? taxDeductionSummary;

  const TaxReport({
    required this.id,
    required this.reportType,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    required this.summary,
    required this.categories,
    required this.transactions,
    required this.metadata,
    required this.createdAt,
    this.generatedAt,
    this.llmAnalysis,
    this.reportId,
    this.status,
    this.totalGains,
    this.totalLosses,
    this.netPnl,
    this.totalIncome,
    this.totalExpenses,
    this.taxDeductionSummary,
  });

  factory TaxReport.fromJson(Map<String, dynamic> json) {
    return TaxReport(
      id: json['id'] as String,
      reportType: json['report_type'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currency: json['currency'] as String? ?? 'USD',
      summary: TaxSummary.fromJson(json['summary'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>)
          .map((c) => TaxCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List<dynamic>)
          .map((t) => TaxTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      generatedAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at'] as String) 
          : null,
      llmAnalysis: json['llm_analysis'] as String?,
      reportId: json['report_id'] as String?,
      status: json['status'] as String?,
      totalGains: json['total_gains'] != null ? (json['total_gains'] as num).toDouble() : null,
      totalLosses: json['total_losses'] != null ? (json['total_losses'] as num).toDouble() : null,
      netPnl: json['net_pnl'] != null ? (json['net_pnl'] as num).toDouble() : null,
      totalIncome: json['total_income'] != null ? (json['total_income'] as num).toDouble() : null,
      totalExpenses: json['total_expenses'] != null ? (json['total_expenses'] as num).toDouble() : null,
      taxDeductionSummary: json['tax_deduction_summary'] as Map<String, dynamic>?,
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
      'categories': categories.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
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

class TaxSummary {
  final double totalIncome;
  final double totalDeductions;
  final double taxableIncome;
  final double totalTaxOwed;
  final double totalTaxPaid;
  final double netTaxOwed;
  final Map<String, double> taxBreakdown;
  final Map<String, double> incomeBreakdown;
  final Map<String, double> deductionBreakdown;

  const TaxSummary({
    required this.totalIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.totalTaxOwed,
    required this.totalTaxPaid,
    required this.netTaxOwed,
    required this.taxBreakdown,
    required this.incomeBreakdown,
    required this.deductionBreakdown,
  });

  factory TaxSummary.fromJson(Map<String, dynamic> json) {
    return TaxSummary(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalDeductions: (json['total_deductions'] as num).toDouble(),
      taxableIncome: (json['taxable_income'] as num).toDouble(),
      totalTaxOwed: (json['total_tax_owed'] as num).toDouble(),
      totalTaxPaid: (json['total_tax_paid'] as num).toDouble(),
      netTaxOwed: (json['net_tax_owed'] as num).toDouble(),
      taxBreakdown: Map<String, double>.from(json['tax_breakdown'] as Map<String, dynamic>),
      incomeBreakdown: Map<String, double>.from(json['income_breakdown'] as Map<String, dynamic>),
      deductionBreakdown: Map<String, double>.from(json['deduction_breakdown'] as Map<String, dynamic>),
    );
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

class TaxCategory {
  final String id;
  final String name;
  final String description;
  final double amount;
  final String type; // 'income', 'deduction', 'tax'
  final List<TaxSubCategory> subCategories;

  const TaxCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.type,
    required this.subCategories,
  });

  factory TaxCategory.fromJson(Map<String, dynamic> json) {
    return TaxCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      subCategories: (json['sub_categories'] as List<dynamic>? ?? [])
          .map((s) => TaxSubCategory.fromJson(s as Map<String, dynamic>))
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
      'sub_categories': subCategories.map((s) => s.toJson()).toList(),
    };
  }
}

class TaxSubCategory {
  final String id;
  final String name;
  final double amount;
  final String description;

  const TaxSubCategory({
    required this.id,
    required this.name,
    required this.amount,
    required this.description,
  });

  factory TaxSubCategory.fromJson(Map<String, dynamic> json) {
    return TaxSubCategory(
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

class TaxTransaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime transactionDate;
  final String currency;
  final String? reference;
  final Map<String, dynamic> metadata;

  const TaxTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.transactionDate,
    required this.currency,
    this.reference,
    required this.metadata,
  });

  factory TaxTransaction.fromJson(Map<String, dynamic> json) {
    return TaxTransaction(
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

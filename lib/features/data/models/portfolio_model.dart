
import '../../domain/entities/portfolio.dart';

class PortfolioModel {
  final bool success;
  final double totalValue;
  final String currency;
  final List<PortfolioBreakdownModel> breakdown;

  const PortfolioModel({
    required this.success,
    required this.totalValue,
    required this.currency,
    required this.breakdown,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      success: json['success'] as bool,
      totalValue: (json['total_value'] as num).toDouble(),
      currency: json['currency'] as String,
      breakdown: (json['breakdown'] as List<dynamic>)
          .map((b) => PortfolioBreakdownModel.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'total_value': totalValue,
      'currency': currency,
      'breakdown': breakdown.map((b) => b.toJson()).toList(),
    };
  }

  Portfolio toEntity() {
    return Portfolio(
      success: success,
      totalValue: totalValue,
      currency: currency,
      breakdown: breakdown.map((b) => b.toEntity()).toList(),
    );
  }
}

class PortfolioBreakdownModel {
  final String cryptocurrency;
  final double amount;
  final double currentPrice;
  final double value;
  final String currency;

  const PortfolioBreakdownModel({
    required this.cryptocurrency,
    required this.amount,
    required this.currentPrice,
    required this.value,
    required this.currency,
  });

  factory PortfolioBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PortfolioBreakdownModel(
      cryptocurrency: json['cryptocurrency'] as String,
      amount: (json['amount'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cryptocurrency': cryptocurrency,
      'amount': amount,
      'current_price': currentPrice,
      'value': value,
      'currency': currency,
    };
  }

  PortfolioBreakdown toEntity() {
    return PortfolioBreakdown(
      cryptocurrency: cryptocurrency,
      amount: amount,
      currentPrice: currentPrice,
      value: value,
      currency: currency,
    );
  }
}
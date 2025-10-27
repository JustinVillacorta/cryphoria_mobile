
class Portfolio {
  final bool success;
  final double totalValue;
  final String currency;
  final List<PortfolioBreakdown> breakdown;

  const Portfolio({
    required this.success,
    required this.totalValue,
    required this.currency,
    required this.breakdown,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      success: json['success'] as bool,
      totalValue: (json['total_value'] as num).toDouble(),
      currency: json['currency'] as String,
      breakdown: (json['breakdown'] as List<dynamic>)
          .map((b) => PortfolioBreakdown.fromJson(b as Map<String, dynamic>))
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
}

class PortfolioBreakdown {
  final String cryptocurrency;
  final double amount;
  final double currentPrice;
  final double value;
  final String currency;

  const PortfolioBreakdown({
    required this.cryptocurrency,
    required this.amount,
    required this.currentPrice,
    required this.value,
    required this.currency,
  });

  factory PortfolioBreakdown.fromJson(Map<String, dynamic> json) {
    return PortfolioBreakdown(
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
}
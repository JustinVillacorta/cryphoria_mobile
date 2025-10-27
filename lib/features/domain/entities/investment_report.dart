class InvestmentTransaction {
  final String transactionHash;
  final String timestamp;
  final String fromAddress;
  final String toAddress;
  final String direction;
  final double amount;
  final String currency;
  final String investorName;
  final String companyName;
  final String number;
  final String recipientName;
  final String recipientCompany;
  final String descriptionReceiverPov;

  const InvestmentTransaction({
    required this.transactionHash,
    required this.timestamp,
    required this.fromAddress,
    required this.toAddress,
    required this.direction,
    required this.amount,
    required this.currency,
    required this.investorName,
    required this.companyName,
    required this.number,
    required this.recipientName,
    required this.recipientCompany,
    required this.descriptionReceiverPov,
  });

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      transactionHash: json['transaction_hash'] ?? '',
      timestamp: json['timestamp'] ?? '',
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      direction: json['direction'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      investorName: json['investor_name'] ?? '',
      companyName: json['company_name'] ?? '',
      number: json['number'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientCompany: json['recipient_company'] ?? '',
      descriptionReceiverPov: json['description_receiver_pov'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_hash': transactionHash,
      'timestamp': timestamp,
      'from_address': fromAddress,
      'to_address': toAddress,
      'direction': direction,
      'amount': amount,
      'currency': currency,
      'investor_name': investorName,
      'company_name': companyName,
      'number': number,
      'recipient_name': recipientName,
      'recipient_company': recipientCompany,
      'description_receiver_pov': descriptionReceiverPov,
    };
  }
}

class InvestmentStatistics {
  final bool success;
  final int count;
  final List<InvestmentTransaction> investments;

  const InvestmentStatistics({
    required this.success,
    required this.count,
    required this.investments,
  });

  factory InvestmentStatistics.fromJson(Map<String, dynamic> json) {
    return InvestmentStatistics(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      investments: (json['investments'] as List<dynamic>?)
          ?.map((investment) => InvestmentTransaction.fromJson(investment))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'investments': investments.map((investment) => investment.toJson()).toList(),
    };
  }

  double get totalReceived {
    return investments
        .where((transaction) => transaction.direction == 'RECEIVED')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalSent {
    return investments
        .where((transaction) => transaction.direction == 'SENT')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  int get receivedCount {
    return investments.where((transaction) => transaction.direction == 'RECEIVED').length;
  }

  int get sentCount {
    return investments.where((transaction) => transaction.direction == 'SENT').length;
  }
}
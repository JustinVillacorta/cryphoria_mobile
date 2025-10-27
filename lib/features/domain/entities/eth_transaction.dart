class EthTransaction {
  final String id;
  final String transactionHash;
  final String fromAddress;
  final String toAddress;
  final double amountEth;
  final double gasPrice;
  final int gasLimit;
  final int gasUsed;
  final double gasCostEth;
  final double totalCostEth;
  final String status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? fromWalletName;
  final String? company;
  final String? category;
  final String? description;
  final int confirmations;
  final int chainId;
  final int nonce;

  EthTransaction({
    required this.id,
    required this.transactionHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amountEth,
    required this.gasPrice,
    required this.gasLimit,
    required this.gasUsed,
    required this.gasCostEth,
    required this.totalCostEth,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.fromWalletName,
    this.company,
    this.category,
    this.description,
    this.confirmations = 0,
    this.chainId = 1337,
    this.nonce = 0,
  });
}

class EthTransactionRequest {
  final String? fromWalletId;
  final String? fromAddress;
  final String toAddress;
  final double amount;
  final String privateKey;
  final double? gasPrice;
  final int? gasLimit;
  final String? company;
  final String? category;
  final String? description;

  EthTransactionRequest({
    this.fromWalletId,
    this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.privateKey,
    this.gasPrice,
    this.gasLimit,
    this.company,
    this.category,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'to_address': toAddress,
      'amount': amount.toString(),
      'private_key': privateKey,
    };

    if (fromWalletId != null) json['from_wallet_id'] = fromWalletId;
    if (fromAddress != null) json['from_address'] = fromAddress;
    if (gasPrice != null) json['gas_price'] = gasPrice.toString();
    if (gasLimit != null) json['gas_limit'] = gasLimit.toString();
    if (company != null) json['company'] = company;
    if (category != null) json['category'] = category;
    if (description != null) json['description'] = description;

    return json;
  }
}

class EthTransactionResult {
  final String transactionHash;
  final String fromAddress;
  final String toAddress;
  final double amountEth;
  final double gasPrice;
  final int gasLimit;
  final int gasUsed;
  final double gasCostEth;
  final double totalCostEth;
  final String status;
  final int chainId;
  final int nonce;
  final String? fromWalletName;
  final String? company;
  final String? category;
  final String? description;
  final DateTime timestamp;
  final bool accountingProcessed;

  EthTransactionResult({
    required this.transactionHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amountEth,
    required this.gasPrice,
    required this.gasLimit,
    required this.gasUsed,
    required this.gasCostEth,
    required this.totalCostEth,
    required this.status,
    required this.chainId,
    required this.nonce,
    this.fromWalletName,
    this.company,
    this.category,
    this.description,
    required this.timestamp,
    this.accountingProcessed = false,
  });

  factory EthTransactionResult.fromJson(Map<String, dynamic> json) {
    return EthTransactionResult(
      transactionHash: json['transaction_hash'] ?? '',
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      amountEth: double.tryParse(json['amount_eth']?.toString() ?? '0') ?? 0.0,
      gasPrice: double.tryParse(json['gas_price_gwei']?.toString() ?? '0') ?? 0.0,
      gasLimit: int.tryParse(json['gas_limit']?.toString() ?? '0') ?? 0,
      gasUsed: int.tryParse(json['gas_used']?.toString() ?? '0') ?? 0,
      gasCostEth: double.tryParse(json['gas_cost_eth']?.toString() ?? '0') ?? 0.0,
      totalCostEth: double.tryParse(json['total_cost_eth']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      chainId: int.tryParse(json['chain_id']?.toString() ?? '1337') ?? 1337,
      nonce: int.tryParse(json['nonce']?.toString() ?? '0') ?? 0,
      fromWalletName: json['from_wallet_name'],
      company: json['company'],
      category: json['category'],
      description: json['description'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      accountingProcessed: json['accounting_processed'] ?? false,
    );
  }
}

class GasEstimate {
  final int gasLimit;
  final double gasPriceGwei;
  final double estimatedCostEth;
  final double slowGasPrice;
  final double standardGasPrice;
  final double fastGasPrice;

  GasEstimate({
    required this.gasLimit,
    required this.gasPriceGwei,
    required this.estimatedCostEth,
    required this.slowGasPrice,
    required this.standardGasPrice,
    required this.fastGasPrice,
  });

  factory GasEstimate.fromJson(Map<String, dynamic> json) {
    return GasEstimate(
      gasLimit: int.tryParse(json['gas_limit']?.toString() ?? '21000') ?? 21000,
      gasPriceGwei: double.tryParse(json['gas_price_gwei']?.toString() ?? '20') ?? 20.0,
      estimatedCostEth: double.tryParse(json['estimated_cost_eth']?.toString() ?? '0') ?? 0.0,
      slowGasPrice: double.tryParse(json['slow_gas_price']?.toString() ?? '10') ?? 10.0,
      standardGasPrice: double.tryParse(json['standard_gas_price']?.toString() ?? '20') ?? 20.0,
      fastGasPrice: double.tryParse(json['fast_gas_price']?.toString() ?? '30') ?? 30.0,
    );
  }
}

class GasEstimateRequest {
  final String fromAddress;
  final String toAddress;
  final double amount;

  GasEstimateRequest({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_address': fromAddress,
      'to_address': toAddress,
      'amount': amount.toString(),
    };
  }
}

class EthTransactionStatus {
  final String transactionHash;
  final String status;
  final String fromAddress;
  final String toAddress;
  final double amountEth;
  final double gasPrice;
  final int gasLimit;
  final int? gasUsed;
  final double gasCostEth;
  final double totalCostEth;
  final int? blockNumber;
  final int confirmations;
  final int nonce;
  final int chainId;

  EthTransactionStatus({
    required this.transactionHash,
    required this.status,
    required this.fromAddress,
    required this.toAddress,
    required this.amountEth,
    required this.gasPrice,
    required this.gasLimit,
    this.gasUsed,
    required this.gasCostEth,
    required this.totalCostEth,
    this.blockNumber,
    required this.confirmations,
    required this.nonce,
    required this.chainId,
  });

  factory EthTransactionStatus.fromJson(Map<String, dynamic> json) {
    return EthTransactionStatus(
      transactionHash: json['transaction_hash'] ?? '',
      status: json['status'] ?? 'pending',
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      amountEth: double.tryParse(json['amount_eth']?.toString() ?? '0') ?? 0.0,
      gasPrice: double.tryParse(json['gas_price_gwei']?.toString() ?? '0') ?? 0.0,
      gasLimit: int.tryParse(json['gas_limit']?.toString() ?? '0') ?? 0,
      gasUsed: int.tryParse(json['gas_used']?.toString() ?? '0'),
      gasCostEth: double.tryParse(json['gas_cost_eth']?.toString() ?? '0') ?? 0.0,
      totalCostEth: double.tryParse(json['total_cost_eth']?.toString() ?? '0') ?? 0.0,
      blockNumber: int.tryParse(json['block_number']?.toString() ?? '0'),
      confirmations: int.tryParse(json['confirmations']?.toString() ?? '0') ?? 0,
      nonce: int.tryParse(json['nonce']?.toString() ?? '0') ?? 0,
      chainId: int.tryParse(json['chain_id']?.toString() ?? '1337') ?? 1337,
    );
  }
}
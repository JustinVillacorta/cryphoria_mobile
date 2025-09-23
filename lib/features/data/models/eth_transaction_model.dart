import '../../domain/entities/eth_transaction.dart';

class EthTransactionModel extends EthTransaction {
  EthTransactionModel({
    required super.id,
    required super.transactionHash,
    required super.fromAddress,
    required super.toAddress,
    required super.amountEth,
    required super.gasPrice,
    required super.gasLimit,
    required super.gasUsed,
    required super.gasCostEth,
    required super.totalCostEth,
    required super.status,
    required super.createdAt,
    super.confirmedAt,
    super.fromWalletName,
    super.company,
    super.category,
    super.description,
    super.confirmations,
    super.chainId,
    super.nonce,
  });

  factory EthTransactionModel.fromJson(Map<String, dynamic> json) {
    return EthTransactionModel(
      id: json['_id']?.toString() ?? '',
      transactionHash: json['tx_hash'] ?? '',
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      amountEth: double.tryParse(json['amount_eth']?.toString() ?? '0') ?? 0.0,
      gasPrice: double.tryParse(json['gas_price_gwei']?.toString() ?? '0') ?? 0.0,
      gasLimit: int.tryParse(json['gas_limit']?.toString() ?? '0') ?? 0,
      gasUsed: int.tryParse(json['gas_used']?.toString() ?? '0') ?? 0,
      gasCostEth: double.tryParse(json['gas_cost_eth']?.toString() ?? '0') ?? 0.0,
      totalCostEth: double.tryParse(json['total_cost_eth']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.tryParse(json['confirmed_at']) 
          : null,
      fromWalletName: json['from_wallet_name'],
      company: json['company'],
      category: json['category'],
      description: json['description'],
      confirmations: int.tryParse(json['confirmations']?.toString() ?? '0') ?? 0,
      chainId: int.tryParse(json['chain_id']?.toString() ?? '1337') ?? 1337,
      nonce: int.tryParse(json['nonce']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tx_hash': transactionHash,
      'from_address': fromAddress,
      'to_address': toAddress,
      'amount_eth': amountEth.toString(),
      'gas_price_gwei': gasPrice.toString(),
      'gas_limit': gasLimit,
      'gas_used': gasUsed,
      'gas_cost_eth': gasCostEth.toString(),
      'total_cost_eth': totalCostEth.toString(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'from_wallet_name': fromWalletName,
      'company': company,
      'category': category,
      'description': description,
      'confirmations': confirmations,
      'chain_id': chainId,
      'nonce': nonce,
    };
  }

  factory EthTransactionModel.fromDomain(EthTransaction transaction) {
    return EthTransactionModel(
      id: transaction.id,
      transactionHash: transaction.transactionHash,
      fromAddress: transaction.fromAddress,
      toAddress: transaction.toAddress,
      amountEth: transaction.amountEth,
      gasPrice: transaction.gasPrice,
      gasLimit: transaction.gasLimit,
      gasUsed: transaction.gasUsed,
      gasCostEth: transaction.gasCostEth,
      totalCostEth: transaction.totalCostEth,
      status: transaction.status,
      createdAt: transaction.createdAt,
      confirmedAt: transaction.confirmedAt,
      fromWalletName: transaction.fromWalletName,
      company: transaction.company,
      category: transaction.category,
      description: transaction.description,
      confirmations: transaction.confirmations,
      chainId: transaction.chainId,
      nonce: transaction.nonce,
    );
  }
}
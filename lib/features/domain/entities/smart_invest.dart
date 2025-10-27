
class SmartInvestRequest {
  final String toAddress;
  final String amount;
  final bool isInvesting;
  final String investorName;
  final String description;

  SmartInvestRequest({
    required this.toAddress,
    required this.amount,
    required this.isInvesting,
    required this.investorName,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      throw Exception('Invalid amount format: $amount');
    }

    return {
      'to_address': toAddress,
      'amount': parsedAmount,
      'is_investing': isInvesting,
      'investor_name': investorName,
      'description': description,
    };
  }

  factory SmartInvestRequest.fromJson(Map<String, dynamic> json) {
    return SmartInvestRequest(
      toAddress: json['to_address'] as String,
      amount: json['amount'] as String,
      isInvesting: json['is_investing'] as bool,
      investorName: json['investor_name'] as String,
      description: json['description'] as String,
    );
  }
}

class SmartInvestResponse {
  final bool success;
  final String message;
  final SmartInvestData data;

  SmartInvestResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SmartInvestResponse.fromJson(Map<String, dynamic> json) {
    return SmartInvestResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: SmartInvestData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SmartInvestData {
  final String transactionHash;
  final String fromAddress;
  final String fromWalletName;
  final String toAddress;
  final String amountEth;
  final String gasPriceGwei;
  final int gasLimit;
  final int gasUsed;
  final String gasCostEth;
  final String totalCostEth;
  final String status;
  final int chainId;
  final int nonce;
  final String company;
  final String category;
  final String description;
  final String timestamp;
  final String? explorerUrl;
  final bool usedConnectedWallet;
  final String userRole;
  final String walletType;
  final Map<String, dynamic> llmAnalysis;

  SmartInvestData({
    required this.transactionHash,
    required this.fromAddress,
    required this.fromWalletName,
    required this.toAddress,
    required this.amountEth,
    required this.gasPriceGwei,
    required this.gasLimit,
    required this.gasUsed,
    required this.gasCostEth,
    required this.totalCostEth,
    required this.status,
    required this.chainId,
    required this.nonce,
    required this.company,
    required this.category,
    required this.description,
    required this.timestamp,
    this.explorerUrl,
    required this.usedConnectedWallet,
    required this.userRole,
    required this.walletType,
    required this.llmAnalysis,
  });

  factory SmartInvestData.fromJson(Map<String, dynamic> json) {
    return SmartInvestData(
      transactionHash: json['transaction_hash'] as String? ?? '',
      fromAddress: json['from_address'] as String? ?? '',
      fromWalletName: json['from_wallet_name'] as String? ?? '',
      toAddress: json['to_address'] as String? ?? '',
      amountEth: json['amount_eth'] as String? ?? '',
      gasPriceGwei: json['gas_price_gwei'] as String? ?? '',
      gasLimit: json['gas_limit'] as int? ?? 0,
      gasUsed: json['gas_used'] as int? ?? 0,
      gasCostEth: json['gas_cost_eth'] as String? ?? '',
      totalCostEth: json['total_cost_eth'] as String? ?? '',
      status: json['status'] as String? ?? '',
      chainId: json['chain_id'] as int? ?? 0,
      nonce: json['nonce'] as int? ?? 0,
      company: json['company'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      explorerUrl: json['explorer_url'] as String?,
      usedConnectedWallet: json['used_connected_wallet'] as bool? ?? false,
      userRole: json['user_role'] as String? ?? '',
      walletType: json['wallet_type'] as String? ?? '',
      llmAnalysis: json['llm_analysis'] as Map<String, dynamic>? ?? {},
    );
  }
}

class AddressBookEntry {
  final String address;
  final String name;
  final String role;
  final String notes;

  AddressBookEntry({
    required this.address,
    required this.name,
    required this.role,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'role': role,
      'notes': notes,
    };
  }

  factory AddressBookEntry.fromJson(Map<String, dynamic> json) {
    return AddressBookEntry(
      address: json['address'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class AddressBookUpsertRequest {
  final String address;
  final String name;
  final String role;
  final String notes;

  AddressBookUpsertRequest({
    required this.address,
    required this.name,
    required this.role,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'role': role,
      'notes': notes,
    };
  }
}

class AddressBookUpsertResponse {
  final bool success;
  final String message;
  final AddressBookEntry data;

  AddressBookUpsertResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddressBookUpsertResponse.fromJson(Map<String, dynamic> json) {
    return AddressBookUpsertResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: AddressBookEntry.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AddressBookListResponse {
  final bool success;
  final String message;
  final List<AddressBookEntry> data;

  AddressBookListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddressBookListResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];
    List<AddressBookEntry> entries = [];

    if (dataField is List) {
      entries = dataField
          .map((item) => AddressBookEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (dataField is Map<String, dynamic>) {
      entries = [AddressBookEntry.fromJson(dataField)];
    }

    return AddressBookListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: entries,
    );
  }
}

class AddressBookDeleteRequest {
  final String address;

  AddressBookDeleteRequest({
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
    };
  }
}

class AddressBookDeleteResponse {
  final bool success;
  final String message;

  AddressBookDeleteResponse({
    required this.success,
    required this.message,
  });

  factory AddressBookDeleteResponse.fromJson(Map<String, dynamic> json) {
    return AddressBookDeleteResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}
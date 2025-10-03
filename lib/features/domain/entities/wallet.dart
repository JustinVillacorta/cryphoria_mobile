class Wallet {
  final String id;
  final String name;
  final double balance;
  final double balanceInPHP;
  final double balanceInUSD;
  final String address;
  final String walletType;
  final bool isConnected;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    this.balanceInPHP = 0.0,
    this.balanceInUSD = 0.0,
    this.address = '',
    this.walletType = 'MetaMask',
    this.isConnected = false,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      balance: json['balance'] is int
          ? (json['balance'] as int).toDouble()
          : (json['balance'] as double? ?? 0.0),
      balanceInPHP: json['balance_in_php'] is int
          ? (json['balance_in_php'] as int).toDouble()
          : (json['balance_in_php'] as double? ?? 0.0),
      balanceInUSD: json['balance_in_usd'] is int
          ? (json['balance_in_usd'] as int).toDouble()
          : (json['balance_in_usd'] as double? ?? 0.0),
      address: json['address'] as String? ?? '',
      walletType: json['wallet_type'] as String? ?? 'MetaMask',
      isConnected: json['is_connected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'balance_in_php': balanceInPHP,
      'balance_in_usd': balanceInUSD,
      'address': address,
      'wallet_type': walletType,
      'is_connected': isConnected,
    };
  }

  String get displayAddress {
    if (address.isEmpty) return '';
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// ✅ Add this for updating fields easily
  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    double? balanceInPHP,
    double? balanceInUSD,
    String? address,
    String? walletType,
    bool? isConnected,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      balanceInPHP: balanceInPHP ?? this.balanceInPHP,
      balanceInUSD: balanceInUSD ?? this.balanceInUSD,
      address: address ?? this.address,
      walletType: walletType ?? this.walletType,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
class Wallet {
  final String id;
  final String name;
  final String address;
  final double balance;

  Wallet({
    required this.id,
    required this.name,
    required this.address,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      balance: json['balance'] is int
          ? (json['balance'] as int).toDouble()
          : json['balance'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'balance': balance,
    };
  }
}
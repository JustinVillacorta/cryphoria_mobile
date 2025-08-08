class Wallet {
  final String id;
  final String name;
  final String private_key;
  final double balance;

  Wallet({
    required this.id,
    required this.name,
    required this.private_key,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      private_key: json['private_key'] as String,
      balance: json['balance'] is int
          ? (json['balance'] as int).toDouble()
          : json['balance'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'private_key': private_key,
      'balance': balance,
    };
  }
}
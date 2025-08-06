import 'package:dio/dio.dart';
import '../../domain/entities/wallet.dart';

class WalletRemoteDataSource {
  final String baseUrl;
  String token;
  final Dio dio;

  WalletRemoteDataSource({
    this.baseUrl = "http://localhost:8000/api/wallets/",
    required this.token,
    Dio? dio,
  }) : dio = dio ?? Dio();

  Future<List<Wallet>> fetchWallets() async {
    try {
      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
      );
      final walletsJson = response.data["data"]["wallets"] as List;
      return walletsJson.map((json) => Wallet.fromJson(json)).toList();
    } on DioError catch (e) {
      throw Exception("Failed to fetch wallets: ${e.response?.statusCode}");
    }
  }

  Future<Wallet> createWallet(Wallet wallet) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: {
          "name": wallet.name,
          "address": wallet.address,
          // Include additional fields if needed.
        },
        options: Options(
          headers: {
            "Authorization": "Token $token",
            "Content-Type": "application/json",
          },
        ),
      );
      return Wallet.fromJson(response.data["data"]);
    } on DioError catch (e) {
      throw Exception("Failed to add wallet: ${e.response?.statusCode}");
    }
  }

  Future<Wallet> connectWallet({
    required String walletType, // e.g. 'metamask', 'coinbase', 'trust_wallet'
    required String address,
    required String signature,
  }) async {
    final type = walletType.toLowerCase();
    final url = '$baseUrl/connect_$type/';
    final response = await dio.post(
      url,

      options: Options(
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
      ),
      data: {
        'address': address,
        'signature': signature,
        'wallet_name': walletType,
      },
    );
    return Wallet.fromJson(response.data['data']);
  }
}

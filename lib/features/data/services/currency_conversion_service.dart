import 'package:dio/dio.dart';

class CurrencyConversionService {
  final Dio _dio = Dio();
  static const String _coingeckoApiUrl = 'https://api.coingecko.com/api/v3';
  
  // Cache for exchange rates to avoid too many API calls
  static double? _cachedEthToPHPRate;
  static double? _cachedEthToUSDRate;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Converts ETH amount to PHP
  Future<double> convertETHToPHP(double ethAmount) async {
    try {
      final rate = await getETHToPHPRate();
      return ethAmount * rate;
    } catch (e) {
      print('Error converting ETH to PHP: $e');
      return 0.0;
    }
  }

  /// Converts ETH amount to USD
  Future<double> convertETHToUSD(double ethAmount) async {
    try {
      final rate = await getETHToUSDRate();
      return ethAmount * rate;
    } catch (e) {
      print('Error converting ETH to USD: $e');
      return 0.0;
    }
  }

  /// Gets both PHP and USD rates for ETH in a single API call
  Future<Map<String, double>> getETHRates() async {
    // Check if we have valid cached rates
    if (_cachedEthToPHPRate != null && 
        _cachedEthToUSDRate != null &&
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return {
        'php': _cachedEthToPHPRate!,
        'usd': _cachedEthToUSDRate!,
      };
    }

    try {
      final response = await _dio.get(
        '$_coingeckoApiUrl/simple/price',
        queryParameters: {
          'ids': 'ethereum',
          'vs_currencies': 'php,usd',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final phpRate = data['ethereum']['php']?.toDouble() ?? 200000.0;
        final usdRate = data['ethereum']['usd']?.toDouble() ?? 3200.0;
        
        // Cache the rates
        _cachedEthToPHPRate = phpRate;
        _cachedEthToUSDRate = usdRate;
        _lastFetchTime = DateTime.now();
        
        return {
          'php': phpRate,
          'usd': usdRate,
        };
      } else {
        throw Exception('Failed to fetch exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ETH rates: $e');
      // Return fallback rates if API fails
      return {
        'php': 200000.0, // Fallback: 1 ETH ≈ 200,000 PHP
        'usd': 3200.0,   // Fallback: 1 ETH ≈ 3,200 USD
      };
    }
  }

  /// Gets the current ETH to PHP exchange rate
  Future<double> getETHToPHPRate() async {
    final rates = await getETHRates();
    return rates['php'] ?? 200000.0;
  }

  /// Gets the current ETH to USD exchange rate
  Future<double> getETHToUSDRate() async {
    final rates = await getETHRates();
    return rates['usd'] ?? 3200.0;
  }

  /// Formats PHP amount with proper currency formatting
  String formatPHPAmount(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₱${amount.toStringAsFixed(2)}';
    }
  }

  /// Formats USD amount with proper currency formatting
  String formatUSDAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  /// Formats ETH amount with proper decimal places
  String formatETHAmount(double amount) {
    if (amount >= 1.0) {
      return '${amount.toStringAsFixed(4)} ETH';
    } else {
      return '${amount.toStringAsFixed(6)} ETH';
    }
  }
}

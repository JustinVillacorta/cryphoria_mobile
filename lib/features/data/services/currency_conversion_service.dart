import 'package:dio/dio.dart';

class CurrencyConversionService {
  final Dio _dio;
  static const String _backendBaseUrl = 'http://localhost:8000/api';

  /// Constructor accepts Dio instance for backend API calls
  CurrencyConversionService({Dio? dio}) : _dio = dio ?? Dio();

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

  /// Gets both PHP and USD rates for ETH in a single API call from backend
  Future<Map<String, double>> getETHRates() async {
    print('🔄 Fetching real-time ETH rates from backend...');
    
    try {
      // Call backend exchange rate endpoint with correct parameters
      final response = await _dio.get(
        '$_backendBaseUrl/rates/current/',
        queryParameters: {
          'symbols': 'ETH',  // Backend expects 'symbols' not 'crypto_symbol'
          'currency': 'USD', // Get USD first, then convert to PHP
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('💰 Backend exchange rate response: ${response.statusCode}');
      print('📊 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rates = response.data['rates'] as Map<String, dynamic>? ?? {};
        final usdRate = rates['ETH']?.toDouble() ?? 3200.0;
        final phpRate = usdRate * 56.0; // Convert USD to PHP (1 USD ≈ 56 PHP)
        
        print('✅ Real-time rates from backend: USD: \$${usdRate}, PHP: ₱${phpRate}');
        
        return {
          'php': phpRate,
          'usd': usdRate,
        };
      } else {
        throw Exception('Backend response: ${response.data}');
      }
    } catch (e) {
      print('🚨 Error fetching ETH rates from backend: $e');
      
      // Fallback: Try PHP rate directly
      try {
        print('🔄 Trying PHP conversion endpoint...');
        return await _getETHRatesFromConversionEndpoint();
      } catch (conversionError) {
        print('🚨 Error with conversion endpoint fallback: $conversionError');
        
        // Use fallback rates as last resort
        print('⚠️ Using fallback rates - backend unavailable');
        return {
          'php': 179200.0, // Fallback: 1 ETH ≈ 179,200 PHP  
          'usd': 3200.0,   // Fallback: 1 ETH ≈ 3,200 USD
        };
      }
    }
  }

  /// Alternative method using backend conversion endpoint
  Future<Map<String, double>> _getETHRatesFromConversionEndpoint() async {
    print('🔄 Using conversion endpoint fallback...');
    
    final responses = await Future.wait([
      _dio.post(
        '$_backendBaseUrl/conversion/crypto-to-fiat/',
        data: {
          'value': '1',  // Updated to use new API format
          'from': 'ETH',
          'to': 'PHP',
        },
      ),
      _dio.post(
        '$_backendBaseUrl/conversion/crypto-to-fiat/',
        data: {
          'value': '1',  // Updated to use new API format
          'from': 'ETH',
          'to': 'USD',
        },
      ),
    ]);

    final phpResponse = responses[0];
    final usdResponse = responses[1];

    print('💰 PHP conversion response: ${phpResponse.data}');
    print('💰 USD conversion response: ${usdResponse.data}');

    final phpRate = phpResponse.data['converted_amount']?.toDouble() ?? 179200.0;
    final usdRate = usdResponse.data['converted_amount']?.toDouble() ?? 3200.0;

    print('✅ Conversion endpoint rates: USD: \$${usdRate}, PHP: ₱${phpRate}');

    return {
      'php': phpRate,
      'usd': usdRate,
    };
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

  /// Convert cryptocurrency to fiat using the new API format
  Future<Map<String, dynamic>> convertCryptoToFiat({
    required String value,
    required String from,
    required String to,
  }) async {
    print('🔄 Converting $value $from to $to using /api/conversion/crypto-to-fiat/');
    
    try {
      final response = await _dio.post(
        '$_backendBaseUrl/conversion/crypto-to-fiat/',
        data: {
          'value': value,
          'from': from,
          'to': to,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('💰 Crypto to fiat conversion response: ${response.statusCode}');
      print('📊 Full response data: ${response.data}');
      print('📊 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Check if response has success field
        if (response.data is Map && response.data.containsKey('success')) {
          if (response.data['success'] == true) {
            // Parse the actual response structure: {"success":true,"content":[{"crypto":"ETH","fiat":"PHP","quantity":1.0,"unit_price":259466.0,"total_value":259466.0}]}
            final content = response.data['content'] as List?;
            if (content != null && content.isNotEmpty) {
              final conversionData = content[0] as Map<String, dynamic>;
              final totalValue = conversionData['total_value'] as num? ?? 0.0;
              final result = {
                'converted_amount': totalValue,
                'unit_price': conversionData['unit_price'],
                'quantity': conversionData['quantity'],
                'crypto': conversionData['crypto'],
                'fiat': conversionData['fiat'],
              };
              print('✅ Conversion successful: $value $from = $totalValue $to');
              print('📊 Result data: $result');
              return result;
            } else {
              throw Exception('Conversion failed: No content in response');
            }
          } else {
            throw Exception('Conversion failed: ${response.data['error'] ?? 'Unknown error'}');
          }
        } else {
          // Response doesn't have success field, assume it's successful if status is 200
          final result = response.data is Map ? response.data : {'converted_amount': response.data};
          print('✅ Conversion successful (no success field): $value $from = ${result['converted_amount']} $to');
          print('📊 Result data: $result');
          return result;
        }
      } else {
        throw Exception('Conversion failed with status ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      print('🚨 Error converting crypto to fiat: $e');
      rethrow;
    }
  }
}

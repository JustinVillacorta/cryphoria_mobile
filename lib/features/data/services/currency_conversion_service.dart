import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CurrencyConversionService {
  final Dio _dio;
  static const String _backendBaseUrl = 'http://localhost:8000/api';

  CurrencyConversionService({Dio? dio}) : _dio = dio ?? Dio();

  Future<double> convertETHToPHP(double ethAmount) async {
    try {
      final rate = await getETHToPHPRate();
      return ethAmount * rate;
    } catch (e) {
      debugPrint('Error converting ETH to PHP: $e');
      return 0.0;
    }
  }

  Future<double> convertETHToUSD(double ethAmount) async {
    try {
      final rate = await getETHToUSDRate();
      return ethAmount * rate;
    } catch (e) {
      debugPrint('Error converting ETH to USD: $e');
      return 0.0;
    }
  }

  Future<Map<String, double>> getETHRates() async {
    debugPrint('🔄 Fetching real-time ETH rates from backend...');
    
    try {
      final response = await _dio.get(
        '$_backendBaseUrl/rates/current/',
        queryParameters: {
          'symbols': 'ETH',
          'currency': 'USD',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('💰 Backend exchange rate response: ${response.statusCode}');
      debugPrint('📊 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rates = response.data['rates'] as Map<String, dynamic>? ?? {};
        final usdRate = rates['ETH']?.toDouble() ?? 3200.0;
        final phpRate = usdRate * 56.0;
        
        debugPrint('✅ Real-time rates from backend: USD: \$$usdRate, PHP: ₱$phpRate');
        
        return {
          'php': phpRate,
          'usd': usdRate,
        };
      } else {
        throw Exception('Backend response: ${response.data}');
      }
    } catch (e) {
      debugPrint('🚨 Error fetching ETH rates from backend: $e');
      
      try {
        debugPrint('🔄 Trying PHP conversion endpoint...');
        return await _getETHRatesFromConversionEndpoint();
      } catch (conversionError) {
        debugPrint('🚨 Error with conversion endpoint fallback: $conversionError');
        
        debugPrint('⚠️ Using fallback rates - backend unavailable');
        return {
          'php': 179200.0,
          'usd': 3200.0,
        };
      }
    }
  }

  Future<Map<String, double>> _getETHRatesFromConversionEndpoint() async {
    debugPrint('🔄 Using conversion endpoint fallback...');
    
    final responses = await Future.wait([
      _dio.post(
        '$_backendBaseUrl/conversion/crypto-to-fiat/',
        data: {
          'value': '1',
          'from': 'ETH',
          'to': 'PHP',
        },
      ),
      _dio.post(
        '$_backendBaseUrl/conversion/crypto-to-fiat/',
        data: {
          'value': '1',
          'from': 'ETH',
          'to': 'USD',
        },
      ),
    ]);

    final phpResponse = responses[0];
    final usdResponse = responses[1];

    debugPrint('💰 PHP conversion response: ${phpResponse.data}');
    debugPrint('💰 USD conversion response: ${usdResponse.data}');

    final phpRate = phpResponse.data['converted_amount']?.toDouble() ?? 179200.0;
    final usdRate = usdResponse.data['converted_amount']?.toDouble() ?? 3200.0;

    debugPrint('✅ Conversion endpoint rates: USD: \$$usdRate, PHP: ₱$phpRate');

    return {
      'php': phpRate,
      'usd': usdRate,
    };
  }

  Future<double> getETHToPHPRate() async {
    final rates = await getETHRates();
    return rates['php'] ?? 200000.0;
  }

  Future<double> getETHToUSDRate() async {
    final rates = await getETHRates();
    return rates['usd'] ?? 3200.0;
  }

  String formatPHPAmount(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₱${amount.toStringAsFixed(2)}';
    }
  }

  String formatUSDAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  String formatETHAmount(double amount) {
    if (amount >= 1.0) {
      return '${amount.toStringAsFixed(4)} ETH';
    } else {
      return '${amount.toStringAsFixed(6)} ETH';
    }
  }

  Future<Map<String, dynamic>> convertCryptoToFiat({
    required String value,
    required String from,
    required String to,
  }) async {
    debugPrint('🔄 Converting $value $from to $to using /api/conversion/crypto-to-fiat/');
    
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

      debugPrint('💰 Crypto to fiat conversion response: ${response.statusCode}');
      debugPrint('📊 Full response data: ${response.data}');
      debugPrint('📊 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('success')) {
          if (response.data['success'] == true) {
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
              debugPrint('✅ Conversion successful: $value $from = $totalValue $to');
              debugPrint('📊 Result data: $result');
              return result;
            } else {
              throw Exception('Conversion failed: No content in response');
            }
          } else {
            throw Exception('Conversion failed: ${response.data['error'] ?? 'Unknown error'}');
          }
        } else {
          final result = response.data is Map ? response.data : {'converted_amount': response.data};
          debugPrint('✅ Conversion successful (no success field): $value $from = ${result['converted_amount']} $to');
          debugPrint('📊 Result data: $result');
          return result;
        }
      } else {
        throw Exception('Conversion failed with status ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      debugPrint('🚨 Error converting crypto to fiat: $e');
      rethrow;
    }
  }
}

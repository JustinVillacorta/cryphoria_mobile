import 'package:flutter/material.dart';
import '../../data/services/wallet_service.dart';
import '../../data/services/currency_conversion_service.dart';

/// Example widget demonstrating how to use the fiat exchange functionality
class FiatExchangeExample extends StatefulWidget {
  final WalletService walletService;
  final CurrencyConversionService currencyService;

  const FiatExchangeExample({
    Key? key,
    required this.walletService,
    required this.currencyService,
  }) : super(key: key);

  @override
  State<FiatExchangeExample> createState() => _FiatExchangeExampleState();
}

class _FiatExchangeExampleState extends State<FiatExchangeExample> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'ETH';
  String _toCurrency = 'PHP';
  String _convertedAmount = '';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      setState(() {
        _error = 'Please enter an amount';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _convertedAmount = '';
    });

    try {
      final result = await widget.walletService.convertCryptoToFiat(
        value: _amountController.text,
        from: _fromCurrency,
        to: _toCurrency,
      );

      setState(() {
        _convertedAmount = result['converted_amount']?.toString() ?? '0';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Conversion failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiat Exchange Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Convert Cryptocurrency to Fiat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'ETH', child: Text('ETH')),
                              DropdownMenuItem(value: 'BTC', child: Text('BTC')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _fromCurrency = value ?? 'ETH';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'PHP', child: Text('PHP')),
                              DropdownMenuItem(value: 'USD', child: Text('USD')),
                              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _toCurrency = value ?? 'PHP';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _convertCurrency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Convert'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_convertedAmount.isNotEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conversion Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_amountController.text} $_fromCurrency = $_convertedAmount $_toCurrency',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Usage Example',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '''// Using WalletService
final result = await walletService.convertCryptoToFiat(
  value: '5',
  from: 'ETH',
  to: 'PHP',
);

// Using CurrencyConversionService directly
final result = await currencyService.convertCryptoToFiat(
  value: '5',
  from: 'ETH',
  to: 'PHP',
);''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

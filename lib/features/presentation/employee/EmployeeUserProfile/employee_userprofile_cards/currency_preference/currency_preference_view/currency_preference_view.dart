import 'package:flutter/material.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String? selectedCryptocurrency = 'ETH';
  String? selectedFiatCurrency = 'USD';

  final List<String> cryptocurrencies = [
    'ETH', 'BTC', 'USDC', 'USDT', 'DAI', 'SOL'
  ];

  final List<String> fiatCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'PHP', 'AUD'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Currency',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Currency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred currencies for displaying balances',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Preferred Cryptocurrency Section
            const Text(
              'Preferred Cryptocurrency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildCurrencyGrid(
              currencies: cryptocurrencies,
              selectedCurrency: selectedCryptocurrency,
              onCurrencySelected: (currency) {
                setState(() {
                  selectedCryptocurrency = currency;
                });
              },
            ),

            const SizedBox(height: 32),

            // Preferred Fiat Currency Section
            const Text(
              'Preferred Fiat Currency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildCurrencyGrid(
              currencies: fiatCurrencies,
              selectedCurrency: selectedFiatCurrency,
              onCurrencySelected: (currency) {
                setState(() {
                  selectedFiatCurrency = currency;
                });
              },
            ),

            const Spacer(),

            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle save changes
                      _saveChanges();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9747FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyGrid({
    required List<String> currencies,
    required String? selectedCurrency,
    required Function(String) onCurrencySelected,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final currency = currencies[index];
        final isSelected = currency == selectedCurrency;

        return GestureDetector(
          onTap: () => onCurrencySelected(currency),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF9747FF).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Color(0xFF9747FF)! : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                currency,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Color(0xFF9747FF) : Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveChanges() {
    // Handle saving the selected currencies
    // You can add your logic here to save to preferences, API, etc.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Preferences Saved'),
          content: Text(
            'Cryptocurrency: $selectedCryptocurrency\nFiat Currency: $selectedFiatCurrency',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Example usage:
// To use this screen, simply navigate to it:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const CurrencyScreen()),
// );
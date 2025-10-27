import 'package:flutter/material.dart';

class SellSharesBottomSheet extends StatefulWidget {
  const SellSharesBottomSheet({super.key});

  @override
  State<SellSharesBottomSheet> createState() => _SellSharesBottomSheetState();
}

class _SellSharesBottomSheetState extends State<SellSharesBottomSheet> {
  int currentStep = 1;
  String selectedCompany = '';
  String selectedWallet = '';
  int sharesToSell = 0;
  double saleValue = 0.0;
  double fee = 0.0;
  double netPayout = 0.0;
  bool isProcessing = false;

  final TextEditingController shareController = TextEditingController();

  final List<Map<String, dynamic>> availableCompanies = [
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'shares': 21, 'value': 3250.75},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'shares': 15, 'value': 4180.25},
    {'symbol': 'JPM', 'name': 'JPMorgan Chase & Co.', 'shares': 8, 'value': 1890.50},
  ];

  final List<Map<String, dynamic>> wallets = [
    {
      'name': 'MetaMask',
      'address': '0x71C2_97eF',
      'connected': true,
      'icon': Icons.account_balance_wallet,
    },
    {
      'name': 'Thrust Wallet',
      'address': '0x71C2_97eF',
      'connected': false,
      'icon': Icons.wallet,
    },
    {
      'name': 'Coinbase',
      'address': '0x71C2_97eF',
      'connected': false,
      'icon': Icons.currency_bitcoin,
    },
  ];

  @override
  void dispose() {
    shareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (currentStep > 1) {
                          setState(() => currentStep--);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Text(
                        'Sell Shares',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index + 1 <= currentStep
                                ? Colors.red[600]
                                : Colors.grey[300],
                            border: Border.all(
                              color: index + 1 <= currentStep ? Colors.red[600]! : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index + 1 <= currentStep ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (index < 2)
                          Container(
                            width: 60,
                            height: 2,
                            color: index + 1 < currentStep ? Colors.red[600] : Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Sell Shares',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: currentStep >= 1 ? Colors.red[600] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Payout Wallet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: currentStep >= 2 ? Colors.red[600] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Confirm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: currentStep >= 3 ? Colors.red[600] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildStepContent(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildBottomAction(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 1:
        return _buildSelectCompanyStep();
      case 2:
        return _buildPayoutWalletStep();
      case 3:
        return _buildConfirmStep();
      case 4:
        return _buildProcessingStep();
      case 5:
        return _buildSuccessStep();
      default:
        return Container();
    }
  }

  Widget _buildSelectCompanyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sell Shares',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Available Company',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: availableCompanies.map((company) {
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedCompany = company['symbol']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedCompany == company['symbol']
                        ? Colors.red[50]
                        : Colors.grey[100],
                    border: Border.all(
                      color: selectedCompany == company['symbol']
                          ? Colors.red[600]!
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      company['symbol'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selectedCompany == company['symbol']
                            ? Colors.red[600]
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        if (selectedCompany.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available to sell:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                '${availableCompanies.firstWhere((c) => c['symbol'] == selectedCompany)['shares']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current value:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${availableCompanies.firstWhere((c) => c['symbol'] == selectedCompany)['value'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Shares to Sell',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: shareController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '23',
              hintStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            onChanged: (value) {
              setState(() {
                sharesToSell = int.tryParse(value) ?? 0;
                _calculateSaleValue();
              });
            },
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shares remaining after sale:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                '${availableCompanies.firstWhere((c) => c['symbol'] == selectedCompany)['shares'] - sharesToSell}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Sale Value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '\$ ${saleValue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPayoutWalletStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Payout Wallet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),

        ...wallets.map((wallet) => GestureDetector(
          onTap: () => setState(() => selectedWallet = wallet['name']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedWallet == wallet['name']
                    ? Colors.red[600]!
                    : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedWallet == wallet['name']
                  ? Colors.red[50]
                  : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: wallet['connected'] ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    wallet['icon'],
                    color: wallet['connected'] ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        wallet['address'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (wallet['connected'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Review & Confirm',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),

        _buildDetailRow('Company', 'Amazon Co.'),
        _buildDetailRow('Shares to Sell', '21'),
        _buildDetailRow('Price per Share', '\$0.00'),
        _buildDetailRow('Sale Value', '\$NaN'),
        _buildDetailRow('Fee (0.5%)', '\$NaN'),
        _buildDetailRow('Net Payout', '\$NaN', isTotal: true),

        const SizedBox(height: 24),

        const Text(
          'Payout Wallet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'MetaMask',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => currentStep = 2),
                child: const Text('Change'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Important Information\nOnce confirmed, this sale cannot be reversed. The market price may fluctuate slightly between confirmation and execution.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple[100],
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Processing Your Sale',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please wait while we process your\ntransaction...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 40,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Sale Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your sale of \$NaN has been processed\nsuccessfully.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDetailRow('Company', 'Unknown Asset'),
              _buildDetailRow('Shares Sold:', '32'),
              _buildDetailRow('Sale Value:', '\$NaN'),
              _buildDetailRow('Fee:', '\$NaN'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    if (currentStep == 4) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => currentStep = 5);
        }
      });
      return const SizedBox();
    }

    if (currentStep == 5) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Back to home',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _canContinue() ? _handleContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              currentStep == 3 ? 'Confirm Sale' : 'Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canContinue() {
    switch (currentStep) {
      case 1:
        return selectedCompany.isNotEmpty && sharesToSell > 0;
      case 2:
        return selectedWallet.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleContinue() {
    if (currentStep == 3) {
      setState(() => currentStep = 4);
    } else if (currentStep < 3) {
      setState(() => currentStep++);
    }
  }

  void _calculateSaleValue() {
    if (selectedCompany.isNotEmpty && sharesToSell > 0) {
      final company = availableCompanies.firstWhere((c) => c['symbol'] == selectedCompany);
      final pricePerShare = company['value'] / company['shares'];
      saleValue = pricePerShare * sharesToSell;
      fee = saleValue * 0.005;
      netPayout = saleValue - fee;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invest/investment_success_screen.dart';

class InvestmentConfirmationScreen extends StatefulWidget {
  final String companyName;
  final String companySymbol;
  final String companyPrice;
  final String selectedWallet;
  final double investmentAmount;
  final String investmentFrequency;
  final double shares;

  const InvestmentConfirmationScreen({
    super.key,
    required this.companyName,
    required this.companySymbol,
    required this.companyPrice,
    required this.selectedWallet,
    required this.investmentAmount,
    required this.investmentFrequency,
    required this.shares,
  });

  @override
  State<InvestmentConfirmationScreen> createState() => _InvestmentConfirmationScreenState();
}

class _InvestmentConfirmationScreenState extends State<InvestmentConfirmationScreen> {
  bool _agreesToTerms = false;

  double get _estimatedFee {
    return widget.investmentAmount * 0.02; // 2% fee
  }

  double get _equivalentEth {
    return widget.investmentAmount / 2750; // Assuming 1 ETH = $2750
  }

  String get _walletAddress {
    switch (widget.selectedWallet) {
      case 'MetaMask':
        return '0x7C67...87BF';
      case 'Coinbase Wallet':
        return '0x254B...87BF';
      case 'Trust Wallet':
        return '0x3C9A...2DEF';
      default:
        return '0x254B...87BF';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crypto Assets',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Confirm Investment Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Investment Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildDetailRow('Company:', widget.companyName),
                  _buildDetailRow('Shares:', '${widget.shares.toStringAsFixed(4)} shares'),
                  _buildDetailRow('Price per share:', widget.companyPrice),
                  _buildDetailRow('Investment Amount:', 
                      '${_equivalentEth.toStringAsFixed(4)} ETH\n\$${widget.investmentAmount.toStringAsFixed(2)} USD'),
                  _buildDetailRow('Funding Source:', 
                      '${widget.selectedWallet} ($_walletAddress)'),
                  _buildDetailRow('Frequency:', widget.investmentFrequency),
                  _buildDetailRow('Estimated Fee:', 
                      '~${(_estimatedFee / 2750).toStringAsFixed(4)} ETH (\$${_estimatedFee.toStringAsFixed(2)})'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Important Notice
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a demo environment. Past performance is not indicative of future results. Please read our fees and complete terms before confirming your investment.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Terms checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreesToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreesToTerms = value ?? false;
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'I understand the risks and confirm this investment',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Confirm & Invest button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreesToTerms ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentSuccessScreen(
                          companyName: widget.companyName,
                          companySymbol: widget.companySymbol,
                          investmentAmount: widget.investmentAmount,
                          shares: widget.shares,
                        ),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreesToTerms 
                        ? Colors.purple 
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm & Invest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

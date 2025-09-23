import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invest/investment_details_screen.dart';

class WalletSelectionScreen extends StatefulWidget {
  final String companyName;
  final String companySymbol;
  final String companyPrice;

  const WalletSelectionScreen({
    super.key,
    required this.companyName,
    required this.companySymbol,
    required this.companyPrice,
  });

  @override
  State<WalletSelectionScreen> createState() => _WalletSelectionScreenState();
}

class _WalletSelectionScreenState extends State<WalletSelectionScreen> {
  Set<String> expandedWallets = {};

  final List<WalletData> wallets = [
    WalletData(
      name: 'MetaMask',
      ethBalance: '1.24 ETH',
      usdBalance: '\$2,750.67',
      network: 'PNF',
      address: '0x7C67...87BF',
      fiatValue: '\$4,315.60',
      icon: Icons.account_balance_wallet,
      color: Colors.orange,
    ),
    WalletData(
      name: 'Coinbase Wallet',
      ethBalance: '0.68 ETH',
      usdBalance: '\$1,534.32',
      network: 'POLYGON',
      address: '0x254B...Ec30',
      fiatValue: '\$1,948.80',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
    ),
    WalletData(
      name: 'Trust Wallet',
      ethBalance: '0.32 ETH',
      usdBalance: '\$739.42',
      network: 'PNE',
      address: '0x3C9C...J0eE',
      fiatValue: '\$1113.60',
      icon: Icons.security,
      color: Colors.blue[800]!,
    ),
  ];

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
      body: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Wallet and Funding',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Select Wallet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Wallet list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final isExpanded = expandedWallets.contains(wallet.name);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Wallet header
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                expandedWallets.remove(wallet.name);
                              } else {
                                expandedWallets.add(wallet.name);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Wallet icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: wallet.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    wallet.icon,
                                    color: wallet.color,
                                    size: 24,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Wallet info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wallet.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${wallet.ethBalance} • ${wallet.usdBalance} • ${wallet.network}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Expand/collapse icon
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.grey[600],
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Expanded content
                        if (isExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildDetailRow('Address:', wallet.address),
                                _buildDetailRow('Balance:', wallet.ethBalance),
                                _buildDetailRow('Fiat Value:', wallet.fiatValue),
                                
                                const SizedBox(height: 16),
                                
                                // Use This Wallet button
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InvestmentDetailsScreen(
                                            companyName: widget.companyName,
                                            companySymbol: widget.companySymbol,
                                            companyPrice: widget.companyPrice,
                                            selectedWallet: wallet.name,
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue[50],
                                      foregroundColor: Colors.blue[700],
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Use This Wallet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class WalletData {
  final String name;
  final String ethBalance;
  final String usdBalance;
  final String network;
  final String address;
  final String fiatValue;
  final IconData icon;
  final Color color;

  WalletData({
    required this.name,
    required this.ethBalance,
    required this.usdBalance,
    required this.network,
    required this.address,
    required this.fiatValue,
    required this.icon,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Invest/wallet_selection_screen.dart';

class CompanySelectionScreen extends StatefulWidget {
  final String industry;
  
  const CompanySelectionScreen({
    super.key,
    required this.industry,
  });

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CompanyData> get _companies {
    switch (widget.industry) {
      case 'Technology':
        return [
          CompanyData('Apple Inc.', 'AAPL', '\$198.45', '+2.4%', true),
          CompanyData('Microsoft Corporation', 'MSFT', '\$342.78', '+1.8%', true),
          CompanyData('Alphabet Inc.', 'GOOGL', '\$142.56', '-0.7%', false),
          CompanyData('Amazon.com Inc.', 'AMZN', '\$178.32', '+3.2%', true),
        ];
      case 'Finance':
        return [
          CompanyData('JPMorgan Chase & Co.', 'JPM', '\$175.45', '+0.8%', true),
          CompanyData('Bank of America Corp', 'BAC', '\$32.17', '+1.2%', true),
          CompanyData('Wells Fargo & Company', 'WFC', '\$45.89', '-0.3%', false),
          CompanyData('Goldman Sachs Group Inc', 'GS', '\$287.45', '+2.1%', true),
        ];
      case 'Healthcare':
        return [
          CompanyData('Johnson & Johnson', 'JNJ', '\$156.78', '-0.4%', false),
          CompanyData('Pfizer Inc.', 'PFE', '\$34.12', '+1.9%', true),
          CompanyData('UnitedHealth Group Inc', 'UNH', '\$542.30', '+0.9%', true),
          CompanyData('Merck & Co Inc', 'MRK', '\$108.67', '+1.4%', true),
        ];
      case 'Energy':
        return [
          CompanyData('Exxon Mobil Corporation', 'XOM', '\$112.45', '+3.4%', true),
          CompanyData('Chevron Corporation', 'CVX', '\$165.78', '+2.8%', true),
          CompanyData('ConocoPhillips', 'COP', '\$98.23', '+4.1%', true),
          CompanyData('EOG Resources Inc', 'EOG', '\$134.56', '+2.3%', true),
        ];
      case 'Consumer Goods':
        return [
          CompanyData('Procter & Gamble Co', 'PG', '\$156.78', '+0.6%', true),
          CompanyData('Coca-Cola Company', 'KO', '\$58.93', '+0.9%', true),
          CompanyData('Nike Inc', 'NKE', '\$112.45', '+1.7%', true),
          CompanyData('Home Depot Inc', 'HD', '\$345.67', '+1.2%', true),
        ];
      default:
        return [];
    }
  }

  List<CompanyData> get _filteredCompanies {
    if (_searchQuery.isEmpty) {
      return _companies;
    }
    return _companies.where((company) {
      return company.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             company.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
          'Invest Smart',
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
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Company',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Progress bar
                Row(
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
                      flex: 3,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search companies...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Company list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filteredCompanies.length,
              itemBuilder: (context, index) {
                final company = _filteredCompanies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CompanyCard(
                    company: company,
                    onTap: () {
                      _navigateToWalletSelection(context, company);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWalletSelection(BuildContext context, CompanyData company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletSelectionScreen(
          companyName: company.name,
          companySymbol: company.symbol,
          companyPrice: company.price,
        ),
      ),
    );
  }
}

class CompanyData {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;

  CompanyData(this.name, this.symbol, this.price, this.change, this.isPositive);
}

class CompanyCard extends StatelessWidget {
  final CompanyData company;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Company icon placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Company info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.symbol,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Price and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  company.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company.change,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: company.isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final FakeTransactionsDataSource _dataSource = FakeTransactionsDataSource();
  
  // Filter and sort state
  String _selectedTransactionType = 'All';
  String _selectedSortBy = 'Date';
  final List<String> _transactionTypes = ['All', 'Buy', 'Sell'];
  final List<String> _sortOptions = ['Date', 'Value'];
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filter visibility state
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> transactions = List.from(_dataSource.getTransactions());
    
    // Apply transaction type filter
    if (_selectedTransactionType != 'All') {
      transactions = transactions.where((transaction) {
        if (_selectedTransactionType == 'Buy') {
          return transaction['title'].toString().toLowerCase().contains('purchase') ||
                 transaction['title'].toString().toLowerCase().contains('buy') ||
                 transaction['title'].toString().toLowerCase().contains('bought') ||
                 transaction['type'] == 'buy';
        } else if (_selectedTransactionType == 'Sell') {
          return transaction['title'].toString().toLowerCase().contains('sell') ||
                 transaction['title'].toString().toLowerCase().contains('sold') ||
                 transaction['type'] == 'sell';
        }
        return true;
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((transaction) {
        return transaction['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply sorting
    switch (_selectedSortBy) {
      case 'Value':
        transactions.sort((a, b) {
          double valueA = double.tryParse(a['amount'].toString().replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
          double valueB = double.tryParse(b['amount'].toString().replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
          return valueB.compareTo(valueA); // Descending order
        });
        break;
      case 'Date':
      default:
        // Default is already sorted by date (most recent first)
        break;
    }
    
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;
    
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
          'All Transactions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and filters section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter & Sort row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filter & Sort',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showFilters = !_showFilters;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.purple),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.filter_list, size: 16, color: Colors.purple),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Filters',
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _showFilters ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                                        size: 16, 
                                        color: Colors.purple
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Expandable filters section
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  
                  // Transaction Type filters
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _transactionTypes.map((type) {
                          final isSelected = _selectedTransactionType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTransactionType = type;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.purple : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.purple : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Sort By section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _sortOptions.map((option) {
                          final isSelected = _selectedSortBy == option;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSortBy = option;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.purple : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.purple : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (option == 'Date' && isSelected) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.swap_vert, 
                                      size: 14, 
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Transactions section
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  // Transactions list or empty state
                  Expanded(
                    child: filteredTransactions.isEmpty 
                        ? _buildEmptyState()
                        : _buildTransactionsList(filteredTransactions),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found matching your criteria',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Back to Portfolio',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isBuyTransaction = transaction['title'].toString().toLowerCase().contains('bought') ||
        transaction['title'].toString().toLowerCase().contains('purchase') ||
        transaction['title'].toString().toLowerCase().contains('buy') ||
        transaction['type'] == 'buy';
    
    final bool isSellTransaction = transaction['title'].toString().toLowerCase().contains('sell') ||
        transaction['type'] == 'sell';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction icon with buy/sell indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBuyTransaction 
                  ? Colors.green.withOpacity(0.1)
                  : isSellTransaction
                    ? Colors.red.withOpacity(0.1)
                    : transaction['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuyTransaction 
                  ? Icons.trending_up 
                  : isSellTransaction
                    ? Icons.trending_down
                    : transaction['icon'],
              color: isBuyTransaction 
                  ? Colors.green
                  : isSellTransaction
                    ? Colors.red
                    : transaction['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isBuyTransaction 
                            ? Colors.green 
                            : isSellTransaction 
                              ? Colors.red 
                              : Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isBuyTransaction 
                            ? 'Bought' 
                            : isSellTransaction 
                              ? 'Sell' 
                              : transaction['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction['subtitle'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Amount and details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: transaction['isPositive'] ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              if (transaction['price'] != null || transaction['fee'] != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (transaction['price'] != null) ...[
                      Text(
                        'Price: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        transaction['price'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (transaction['fee'] != null) ...[
                      Text(
                        'Fee: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        transaction['fee'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                Text(
                  'Fee: \$0.00',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

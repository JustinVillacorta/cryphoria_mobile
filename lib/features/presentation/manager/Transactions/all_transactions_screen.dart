import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_details.dart';

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();

  String _selectedTransactionType = 'All';
  String _selectedSortBy = 'Date';
  final List<String> _transactionTypes = ['All', 'Sent', 'Received'];
  final List<String> _sortOptions = ['Date', 'Value'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(walletNotifierProvider.notifier);
      notifier.resetAllTransactions();
      notifier.fetchAllTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(walletNotifierProvider.notifier);
      notifier.loadMoreTransactions();
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    final walletState = ref.watch(walletNotifierProvider);
    List<Map<String, dynamic>> transactions = List.from(walletState.allTransactions);

    if (_selectedTransactionType != 'All') {
      transactions = transactions.where((transaction) {
        if (_selectedTransactionType == 'Sent') {
          return transaction['transaction_category'] == 'SENT' ||
                 transaction['title'].toString().toLowerCase().contains('sent') ||
                 transaction['title'].toString().toLowerCase().contains('purchase') ||
                 transaction['title'].toString().toLowerCase().contains('buy') ||
                 transaction['title'].toString().toLowerCase().contains('bought') ||
                 transaction['type'] == 'buy';
        } else if (_selectedTransactionType == 'Received') {
          return transaction['transaction_category'] == 'RECEIVED' ||
                 transaction['title'].toString().toLowerCase().contains('received') ||
                 transaction['title'].toString().toLowerCase().contains('sell') ||
                 transaction['title'].toString().toLowerCase().contains('sold') ||
                 transaction['type'] == 'sell';
        }
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((transaction) {
        return transaction['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction['transaction_hash']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               transaction['from_address']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               transaction['to_address']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      }).toList();
    }

    switch (_selectedSortBy) {
      case 'Value':
        transactions.sort((a, b) {
          double valueA = _parseAmount(a['amount']?.toString() ?? '0');
          double valueB = _parseAmount(b['amount']?.toString() ?? '0');
          return valueB.compareTo(valueA);
        });
        break;
      case 'Date':
      default:
        transactions.sort((a, b) {
          final aTime = a['created_at'] ?? a['timestamp'] ?? '';
          final bTime = b['created_at'] ?? b['timestamp'] ?? '';
          return bTime.compareTo(aTime);
        });
        break;
    }

    return transactions;
  }

  double _parseAmount(String raw) {
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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

                if (_showFilters) ...[
                  const SizedBox(height: 16),

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

                  Expanded(
                    child: walletState.isLoading && walletState.allTransactions.isEmpty
                        ? _buildLoadingState()
                        : filteredTransactions.isEmpty 
                            ? _buildEmptyState()
                            : _buildTransactionsList(filteredTransactions, walletState),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9747FF)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading transactions...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
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

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions, walletState) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length + (walletState.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9747FF)),
              ),
            ),
          );
        }

        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isSentTransaction = transaction['transaction_category'] == 'SENT' ||
        transaction['title'].toString().toLowerCase().contains('sent') ||
        transaction['title'].toString().toLowerCase().contains('bought') ||
        transaction['title'].toString().toLowerCase().contains('purchase') ||
        transaction['title'].toString().toLowerCase().contains('buy') ||
        transaction['type'] == 'buy';

    final bool isReceivedTransaction = transaction['transaction_category'] == 'RECEIVED' ||
        transaction['title'].toString().toLowerCase().contains('received') ||
        transaction['title'].toString().toLowerCase().contains('sell') ||
        transaction['title'].toString().toLowerCase().contains('sold') ||
        transaction['type'] == 'sell';

    final String amountText = (transaction['amount'] ?? '').toString();
    final double numericAmount = _parseAmount(amountText);
    final bool isPositive = (transaction['isPositive'] as bool?) ?? (numericAmount >= 0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final tx = TransactionData(
            title: (transaction['title'] ?? 'Transaction').toString(),
            subtitle: (transaction['subtitle'] ?? '').toString(),
            amount: numericAmount.abs(),
            isIncome: isPositive,
            dateTime: (transaction['time'] ?? transaction['created_at'] ?? 'Today').toString(),
            category: (transaction['category'] ?? (isPositive ? 'Income' : 'Expense')).toString(),
            notes: (transaction['notes'] ?? '—').toString(),
            transactionId: (transaction['id'] ?? transaction['transactionId'] ?? 'TX-${DateTime.now().millisecondsSinceEpoch}').toString(),
            transactionHash: transaction['transaction_hash']?.toString(),
            fromAddress: transaction['from_address']?.toString(),
            toAddress: transaction['to_address']?.toString(),
            gasCost: transaction['gas_cost']?.toString(),
            gasPrice: transaction['gas_price']?.toString(),
            confirmations: transaction['confirmations'] is int ? transaction['confirmations'] as int : null,
            status: transaction['status']?.toString(),
            network: transaction['network']?.toString() ?? 'Ethereum',
            company: transaction['company']?.toString(),
            description: transaction['description']?.toString(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsWidget(transaction: tx),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSentTransaction 
                      ? Colors.red.withValues(alpha: 0.1)
                      : isReceivedTransaction
                        ? Colors.green.withValues(alpha: 0.1)
                        : (transaction['color'] as Color?)?.withValues(alpha: 0.1) ?? Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSentTransaction 
                      ? Icons.arrow_upward 
                      : isReceivedTransaction
                        ? Icons.arrow_downward
                        : (transaction['icon'] as IconData?) ?? Icons.swap_horiz_rounded,
                  color: isSentTransaction 
                      ? Colors.red
                      : isReceivedTransaction
                        ? Colors.green
                        : (transaction['color'] as Color?) ?? Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSentTransaction 
                                ? Colors.red 
                                : isReceivedTransaction 
                                  ? Colors.green 
                                  : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSentTransaction 
                                ? 'Sent' 
                                : isReceivedTransaction 
                                  ? 'Received' 
                                  : transaction['title']?.toString() ?? 'Transaction',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            transaction['subtitle']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['time']?.toString() ?? transaction['created_at']?.toString() ?? 'Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction['amount']?.toString() ?? '\$0.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
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
                            transaction['price']?.toString() ?? '',
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
                            transaction['fee']?.toString() ?? '',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
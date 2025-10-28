import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_details.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_search_bar.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_filter_section.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_loading_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_empty_state.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_list_item.dart';

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
                TransactionSearchBar(controller: _searchController),
                const SizedBox(height: 16),
                TransactionFilterSection(
                  showFilters: _showFilters,
                  onToggleFilters: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  selectedTransactionType: _selectedTransactionType,
                  transactionTypes: _transactionTypes,
                  onTransactionTypeChanged: (type) {
                    setState(() {
                      _selectedTransactionType = type;
                    });
                  },
                  selectedSortBy: _selectedSortBy,
                  sortOptions: _sortOptions,
                  onSortByChanged: (option) {
                    setState(() {
                      _selectedSortBy = option;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
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
                        ? const TransactionLoadingState()
                        : filteredTransactions.isEmpty 
                            ? TransactionEmptyState(
                                onBackPressed: () => Navigator.pop(context),
                              )
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
        return TransactionListItem(
          transaction: transaction,
          parseAmount: _parseAmount,
          onTap: () => _navigateToTransactionDetails(transaction),
        );
      },
    );
  }

  void _navigateToTransactionDetails(Map<String, dynamic> transaction) {
    final String amountText = (transaction['amount'] ?? '').toString();
    final double numericAmount = _parseAmount(amountText);
    final bool isPositive = (transaction['isPositive'] as bool?) ?? (numericAmount >= 0);

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
  }
}
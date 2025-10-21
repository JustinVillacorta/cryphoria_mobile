import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'send_investment_eth_modal.dart';
import '../providers/smart_invest_providers.dart';
import '../../domain/entities/smart_invest.dart';
import '../../domain/entities/investment_report.dart';

class SmartInvestBottomSheet extends ConsumerStatefulWidget {
  const SmartInvestBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<SmartInvestBottomSheet> createState() => _SmartInvestBottomSheetState();
}

class _SmartInvestBottomSheetState extends ConsumerState<SmartInvestBottomSheet>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  bool isAddingEntry = false;
  bool isEditingEntry = false;
  String editingEntryId = '';
  String newWalletAddress = '';
  String newName = '';
  String newRole = 'Investor';
  String newNotes = '';
  int selectedTabIndex = 0;
  String selectedTransactionFilter = 'ALL'; // ALL, RECEIVED, SENT

  // Persistent controllers — avoid recreating controllers in build (prevents cursor jumping / reversed typing)
  final TextEditingController _walletController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late TabController _tabController;

  final List<String> roles = ['Investor', 'Partner', 'Vendor', 'Client'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
    
    // Load address book entries when the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smartInvestNotifierProvider.notifier).getAddressBookList();
      ref.read(smartInvestNotifierProvider.notifier).getInvestmentStatistics();
    });
  }

  @override
  void dispose() {
    _walletController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartInvestNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Address Book Tab
                isAddingEntry || isEditingEntry ? _buildEntryForm() : _buildAddressBookList(state),
                // Investment Report Tab
                _buildInvestmentReportView(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFF3E5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF873FFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Investment Address Book',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black54, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an entry to send investment ETH',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFF873FFF),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Color(0xFF873FFF),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Address Book'),
          Tab(text: 'Investment Report'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or address',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _startAddingEntry(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF873FFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            children: const [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressBookList(SmartInvestState state) {
    // Show loading state
    if (state.isAddressBookLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading address book...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (state.addressBookError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load address book',
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(
              state.addressBookError!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(smartInvestNotifierProvider.notifier).getAddressBookList(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Convert API data to display format
    final entries = state.addressBookEntries.map((entry) => {
      'id': entry.address,
      'name': entry.name,
      'role': entry.role,
      'walletAddress': entry.address,
      'subRole': entry.notes,
      'icon': Icons.business,
    }).toList();

    print('📋 Address book entries:');
    for (var entry in entries) {
      print('📋 - ${entry['name']}: ${entry['walletAddress']}');
    }

    final filteredEntries = entries.where((entry) {
      if (searchQuery.isEmpty) return true;
      return (entry['name'] as String).toLowerCase().contains(searchQuery.toLowerCase()) ||
          (entry['walletAddress'] as String).toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No entries found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return _buildAddressEntry(entry);
      },
    );
  }

  Widget _buildAddressEntry(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon, name, and role
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3E5FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    entry['icon'] as IconData,
                    color: Color(0xFF873FFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry['subRole'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3E5FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry['role'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7436FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wallet address
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry['walletAddress'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('📤 User clicked on entry: ${entry['name']} (${entry['walletAddress']})');
                      _sendEthToEntry(entry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF873FFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Send ETH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _editEntry(entry),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[600],
                  padding: const EdgeInsets.all(12),
                ),
                IconButton(
                  onPressed: () => _deleteEntry(entry),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red[400],
                  padding: const EdgeInsets.all(12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _cancelForm,
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              Text(
                isEditingEntry ? 'Edit Entry' : 'Add New Entry',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wallet Address Field
          const Text(
            'Wallet Address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _walletController,
            onChanged: (value) => setState(() => newWalletAddress = value),
            decoration: const InputDecoration(
              hintText: '0x...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Name Field
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            onChanged: (value) => setState(() => newName = value),
            decoration: const InputDecoration(
              hintText: 'John Doe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Role Field
          const Text(
            'Role',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: newRole,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    newRole = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Notes Field
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            onChanged: (value) => setState(() => newNotes = value),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Additional notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isEditingEntry ? _updateEntry : _addEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF873FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditingEntry ? 'Update Entry' : 'Add Entry',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startAddingEntry() {
    setState(() {
      isAddingEntry = true;
      isEditingEntry = false;
      editingEntryId = '';
      _resetForm();
    });
  }

  void _cancelForm() {
    setState(() {
      isAddingEntry = false;
      isEditingEntry = false;
      editingEntryId = '';
      _resetForm();
    });
  }

  void _resetForm() {
    newWalletAddress = '';
    newName = '';
    newRole = 'Investor';
    newNotes = '';
    // clear persistent controllers to keep caret behaviour stable
    _walletController.text = '';
    _nameController.text = '';
    _notesController.text = '';
  }

  void _sendEthToEntry(Map<String, dynamic> entry) {
    print('📤 _sendEthToEntry called with entry: $entry');
    print('📋 Recipient Name: ${entry['name']}');
    print('📋 Recipient Address: ${entry['walletAddress']}');

    // Show the Send Investment ETH modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SendInvestmentEthModal(
        recipientName: entry['name'] as String,
        recipientAddress: entry['walletAddress'] as String,
      ),
    );
  }

  void _editEntry(Map<String, dynamic> entry) {
    setState(() {
      isEditingEntry = true;
      isAddingEntry = false;
      editingEntryId = entry['id'];
      newWalletAddress = entry['walletAddress'];
      newName = entry['name'];
      // Convert lowercase role to capitalized for dropdown
      newRole = _capitalizeFirst(entry['role'] as String);
      newNotes = entry['subRole'];
      // set controller texts (do this after updating state so build uses correct controllers)
      _walletController.text = entry['walletAddress'];
      _nameController.text = entry['name'];
      _notesController.text = entry['subRole'];
    });
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _deleteEntry(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Entry'),
              content: Text('Are you sure you want to delete ${entry['name']}?'),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          Navigator.of(dialogContext).pop();

                          try {
                            await ref.read(smartInvestNotifierProvider.notifier).deleteAddressBookEntry(entry['walletAddress']);
                            // Use the original context instead of the dialog context
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entry deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            // Use the original context instead of the dialog context
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete entry: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addEntry() async {
    final wallet = _walletController.text.trim();
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();

    if (wallet.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final request = AddressBookUpsertRequest(
        address: wallet,
        name: name,
        role: newRole,
        notes: notes,
      );

      await ref.read(smartInvestNotifierProvider.notifier).upsertAddressBookEntry(request);

      setState(() {
        _resetForm();
        isAddingEntry = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateEntry() async {
    final wallet = _walletController.text.trim();
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();

    if (wallet.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final request = AddressBookUpsertRequest(
        address: wallet,
        name: name,
        role: newRole,
        notes: notes,
      );

      await ref.read(smartInvestNotifierProvider.notifier).upsertAddressBookEntry(request);

      setState(() {
        _resetForm();
        isEditingEntry = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInvestmentReportView(SmartInvestState state) {
    if (state.isStatisticsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading investment statistics...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.statisticsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load investment statistics',
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(
              state.statisticsError!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(smartInvestNotifierProvider.notifier).getInvestmentStatistics(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.investmentStatistics == null) {
      return const Center(
        child: Text(
          'No investment data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final statistics = state.investmentStatistics!;
    final filteredTransactions = _getFilteredTransactions(statistics.investments);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(statistics),
          const SizedBox(height: 24),
          
          // Transaction Filter Tabs
          _buildTransactionFilterTabs(),
          const SizedBox(height: 16),
          
          // Transaction List
          _buildTransactionList(filteredTransactions),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(InvestmentStatistics statistics) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Received',
            '\$${statistics.totalReceived.toStringAsFixed(2)}',
            const Color(0xFF10B981),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Sent',
            '\$${statistics.totalSent.toStringAsFixed(2)}',
            const Color(0xFFEF4444),
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Transactions',
            '${statistics.count}',
            const Color(0xFF3B82F6),
            Icons.receipt_long,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('ALL', selectedTransactionFilter == 'ALL'),
        const SizedBox(width: 8),
        _buildFilterTab('RECEIVED', selectedTransactionFilter == 'RECEIVED'),
        const SizedBox(width: 8),
        _buildFilterTab('SENT', selectedTransactionFilter == 'SENT'),
      ],
    );
  }

  Widget _buildFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedTransactionFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF873FFF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<InvestmentTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) => _buildTransactionCard(transaction)).toList(),
    );
  }

  Widget _buildTransactionCard(InvestmentTransaction transaction) {
    final isReceived = transaction.direction == 'RECEIVED';
    final color = isReceived ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isReceived ? Icons.arrow_downward : Icons.arrow_upward;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived ? transaction.investorName : transaction.recipientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.descriptionReceiverPov,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(transaction.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _copyToClipboard(transaction.transactionHash),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hash: ${transaction.transactionHash.substring(0, 10)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InvestmentTransaction> _getFilteredTransactions(List<InvestmentTransaction> transactions) {
    if (selectedTransactionFilter == 'ALL') {
      return transactions;
    }
    return transactions.where((transaction) => transaction.direction == selectedTransactionFilter).toList();
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _copyToClipboard(String text) {
    // Note: You'll need to add clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${text.substring(0, 10)}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
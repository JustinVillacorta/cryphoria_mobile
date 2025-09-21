import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_view/home_employee_view.dart';

class SalaryTransactionsScreen extends StatefulWidget {
  const SalaryTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<SalaryTransactionsScreen> createState() =>
      _SalaryTransactionsScreenState();
}

class _SalaryTransactionsScreenState extends State<SalaryTransactionsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> transactions = [
    {
      'date': 'May 31, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Confirmed',
      'statusColor': Color(0xFF10B981),
      'statusBgColor': Color(0xFFECFDF5),
      'company': 'MetaMask'
    },
    {
      'date': 'May 31, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Confirmed',
      'statusColor': Color(0xFF10B981),
      'statusBgColor': Color(0xFFECFDF5),
      'company': 'MetaMask'
    },
    {
      'date': 'May 31, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Pending',
      'statusColor': Color(0xFFFF8C00),
      'statusBgColor': Color(0xFFFFE4B5),
      'company': 'Coinbase'
    },
    {
      'date': 'May 31, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Pending',
      'statusColor': Color(0xFFFF8C00),
      'statusBgColor': Color(0xFFFFE4B5),
      'company': 'Coinbase'
    },
    {
      'date': 'May 31, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Confirmed',
      'statusColor': Color(0xFF10B981),
      'statusBgColor': Color(0xFFECFDF5),
      'company': 'MetaMask'
    },
    {
      'date': 'May 30, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Confirmed',
      'statusColor': Color(0xFF10B981),
      'statusBgColor': Color(0xFFECFDF5),
      'company': 'MetaMask'
    },
    {
      'date': 'May 29, 2023',
      'amount': '0.45 ETH',
      'usdAmount': '\$850.50 USD',
      'status': 'Pending',
      'statusColor': Color(0xFFFF8C00),
      'statusBgColor': Color(0xFFFFE4B5),
      'company': 'Coinbase'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Sticky Header with Back Navigation
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeWidgetTree(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Salary Transactions',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Section (Search, Filter, Transactions)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All', selectedFilter == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Confirmed', selectedFilter == 'Confirmed'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', selectedFilter == 'Pending'),
                  ],
                ),

                const SizedBox(height: 16),

                // Transactions List
                ...transactions.map((transaction) {
                  return _buildTransactionItem(transaction);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['date'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: transaction['statusBgColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: transaction['statusColor'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction['company'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction['usdAmount'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
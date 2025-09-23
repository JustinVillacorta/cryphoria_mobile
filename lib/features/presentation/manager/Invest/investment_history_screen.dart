import 'package:flutter/material.dart';

class InvestmentHistoryScreen extends StatefulWidget {
  const InvestmentHistoryScreen({super.key});

  @override
  State<InvestmentHistoryScreen> createState() => _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends State<InvestmentHistoryScreen> {
  String selectedFilter = 'All';
  String selectedTimeframe = 'All';

  final List<String> filterOptions = ['All', 'Year', 'Quarter', 'Month'];
  final List<String> timeframeOptions = ['All', 'Year', 'Quarter', 'Month'];

  final List<Map<String, dynamic>> historyData = [
    {
      'date': 'Jun 12, 2023',
      'amount': '\$76,250.00',
      'change': '+1.7%',
      'value': '+\$1,340.50',
      'isPositive': true,
    },
    {
      'date': 'Jun 5, 2023',
      'amount': '\$77,010.00',
      'change': '+2.2%',
      'value': '+\$1,740.00',
      'isPositive': true,
    },
    {
      'date': 'May 28, 2023',
      'amount': '\$74,830.00',
      'change': '-1.7%',
      'value': '-\$1,300.00',
      'isPositive': false,
    },
    {
      'date': 'May 15, 2023',
      'amount': '\$75,350.00',
      'change': '+1.4%',
      'value': '+\$1,550.00',
      'isPositive': true,
    },
    {
      'date': 'May 10, 2023',
      'amount': '\$72,060.00',
      'change': '+1.4%',
      'value': '+\$1,800.00',
      'isPositive': true,
    },
    {
      'date': 'May 1, 2023',
      'amount': '\$70,300.00',
      'change': '+6.5%',
      'value': '+\$4,250.00',
      'isPositive': true,
    },
    {
      'date': 'Apr 22, 2023',
      'amount': '\$65,900.00',
      'change': '+5.4%',
      'value': '+\$3,200.00',
      'isPositive': true,
    },
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
          'Investment History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Investment History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track and manage your crypto investments.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Filters Row
            Row(
              children: [
                // Filter by time dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Filter by time',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: selectedFilter,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                          items: filterOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFilter = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Filter button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      DropdownButton<String>(
                        value: selectedTimeframe,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                        dropdownColor: Colors.blue[600],
                        items: timeframeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTimeframe = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Portfolio Growth Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portfolio Growth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Chart placeholder
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: const Center(
                      child: Text(
                        'Portfolio growth chart',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Chart stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Text(
                            '\$65,900.00',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Current:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Text(
                            '\$76,250.00',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Value History Section
            const Text(
              'Value History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // History List
            Expanded(
              child: ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final item = historyData[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['date'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    item['isPositive'] ? Icons.trending_up : Icons.trending_down,
                                    size: 16,
                                    color: item['isPositive'] ? Colors.green[600] : Colors.red[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['change'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item['isPositive'] ? Colors.green[600] : Colors.red[600],
                                      fontWeight: FontWeight.w500,
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
                              item['amount'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['value'],
                              style: TextStyle(
                                fontSize: 12,
                                color: item['isPositive'] ? Colors.green[600] : Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back to Portfolio button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Portfolio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

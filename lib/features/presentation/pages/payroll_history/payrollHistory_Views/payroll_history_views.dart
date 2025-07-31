import 'dart:ui';
import 'package:cryphoria_mobile/features/presentation/widgets/payrollHistoryItem_widget.dart';
import 'package:flutter/material.dart';

class PayrollHistory extends StatefulWidget {
  const PayrollHistory({Key? key}) : super(key: key);

  @override
  State<PayrollHistory> createState() => _PayrollHistoryState();
}

class _PayrollHistoryState extends State<PayrollHistory> {
  int _selectedTab = 0; // 0 = Failed, 1 = Sent
  final _tabs = ['Failed', 'Sent'];

  // Sample data
  final List<Map<String, dynamic>> _history = [
    {
      'avatarUrl': 'https://via.placeholder.com/150',
      'name': 'Yuno Cruz',
      'subtitle': '0x238…c68',
      'amount': '+\$123',
      'date': '21 June 2025',
      'isFailed': true,
      'reason': 'Wallet not found',
    },
    {
      'avatarUrl': 'https://via.placeholder.com/150',
      'name': 'Yuno Cruz',
      'subtitle': '0x238…c68',
      'amount': '+\$123',
      'date': '21 June 2025',
      'isFailed': false,
    },
    // … add more failures or successes as needed …
  ];

  @override
  Widget build(BuildContext context) {
    // filter by the selected tab
    final filtered = _history
        .where((e) => e['isFailed'] == (_selectedTab == 0))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // blurred radial background
          Positioned(
            top: -180,
            left: -100,
            right: -100,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFF5B50FF),
                    Color(0xFF7142FF),
                    Color(0xFF9747FF),
                    Colors.transparent,
                  ],
                  stops: [0.2, 0.4, 0.6, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 2) Top bar: back, title, clear all
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Payroll History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear all logic here
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3) Segmented control (Failed / Sent)
                  // inside your Column:
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final segmentWidth =
                                constraints.maxWidth / _tabs.length;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ToggleButtons(
                                isSelected: List.generate(
                                  _tabs.length,
                                  (i) => i == _selectedTab,
                                ),
                                onPressed: (i) =>
                                    setState(() => _selectedTab = i),
                                borderRadius: BorderRadius.circular(20),
                                borderWidth: 0,
                                borderColor: Colors.transparent,
                                selectedBorderColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                fillColor: const Color(0xFF5B50FF),
                                selectedColor: Colors.white,
                                color: Colors.white70,
                                constraints: BoxConstraints(
                                  minWidth: segmentWidth,
                                  minHeight: 40,
                                ),
                                children: _tabs
                                    .map((t) => Center(child: Text(t)))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4) History list
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final e = filtered[i];
                        return PayrollHistoryItem(
                          avatarUrl: e['avatarUrl'] as String,
                          name: e['name'] as String,
                          subtitle: e['subtitle'] as String,
                          amount: e['amount'] as String,
                          date: e['date'] as String,
                          isFailed: e['isFailed'] as bool,
                          reason: e['reason'] as String?,
                          onTap: () {
                            /* optional tap */
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

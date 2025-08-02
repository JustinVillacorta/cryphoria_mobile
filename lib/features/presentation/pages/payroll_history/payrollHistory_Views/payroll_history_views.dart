import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/domain/entities/payroll_history.dart';
import '../../../widgets/glass_payroll_history_item.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_payroll_data.dart';

class PayrollHistoryScreen extends StatefulWidget {
  const PayrollHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PayrollHistoryScreen> createState() => _PayrollHistoryScreenState();
}

class _PayrollHistoryScreenState extends State<PayrollHistoryScreen> {
  int _selectedTab = 0; // 0 = Failed, 1 = Sent
  final _tabs = ['Failed', 'Sent'];
  final FakePayrollDataSource _payrollDataSource = FakePayrollDataSource();
  late List<PayrollHistory> _history;

  @override
  void initState() {
    super.initState();
    _history = _payrollDataSource.getPayrollHistory();
  }

  void _clearHistory() {
    setState(() {
      _history = _history.where((e) => e.isFailed != (_selectedTab == 0)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter by the selected tab
    final filtered = _history
        .where((e) => e.isFailed == (_selectedTab == 0))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred radial background
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
                  // Top bar: back, title, clear all
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
                        onPressed: _clearHistory,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Segmented control (Failed / Sent)
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final segmentWidth = constraints.maxWidth / _tabs.length;
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
                                onPressed: (i) => setState(() => _selectedTab = i),
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

                  // History list
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final payroll = filtered[i];
                        return GlassPayrollHistoryItem(
                          payroll: payroll,
                          onTap: () {
                            // Optional tap logic
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
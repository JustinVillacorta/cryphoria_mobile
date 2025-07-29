import 'dart:ui';
import 'package:cryphoria_mobile/features/presentation/widgets/cardwallet.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/refresh_icon.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  int _selectedFilter = 0;
  final _filters = ['All', 'Last 30 days', 'Custom'];

  // Dummy data
  final _invoices = List.generate(
    10,
    (i) => {
      'title': 'Expenses',
      'description': 'You paid for Payroll. Please view receipt.',
      'amount': '₱12,950',
      'status': 'Paid',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- blurred radial background ----
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

          // ---- main content ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GlassRefreshIcon(onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Two summary cards
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Total Billed Amount',
                                  style: TextStyle(color: Colors.white54),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '₱12,340',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Paid Invoices',
                                  style: TextStyle(color: Colors.white54),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Segmented control
                  // inside your Column, replacing the old ToggleButtons:
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.white12, // dark pill background for unselected
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ToggleButtons(
                        isSelected: List.generate(
                          _filters.length,
                          (i) => i == _selectedFilter,
                        ),
                        onPressed: (i) => setState(() => _selectedFilter = i),
                        borderRadius: BorderRadius.circular(20),
                        borderWidth: 0, // no border lines
                        selectedBorderColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        splashColor: Colors.transparent, // no splash ripple
                        highlightColor: Colors.transparent,
                    
                        // colors
                        fillColor: const Color(
                          0xFF5B50FF,
                        ), // purple for the selected pill
                        selectedColor: Colors.white, // text color when selected
                        color: Colors.white70, // text color when unselected
                        // sizing
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 100,
                        ),
                    
                        children: _filters.map((f) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(f),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Scrollable list of invoice items
                  Expanded(
                    child: ListView.separated(
                      itemCount: _invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) {
                        final inv = _invoices[idx];
                        return GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side: text + badges
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inv['title']!,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        inv['description']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white12,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              inv['status']!,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white12,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'View receipt',
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Right side: amount
                                Text(
                                  inv['amount']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

// lib/features/presentation/pages/payroll_screen.dart

import 'dart:ui';
import 'package:cryphoria_mobile/features/presentation/widgets/historyWidget.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/payroll_ItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/summary_glass_card.dart';

class payrollScreen extends StatelessWidget {
  const payrollScreen({super.key});

  // Dummy data
  final _employees = const [
    {
      'name': 'Yuno Cruz',
      'subtitle': '0x238…c68',
      'amount': '+\$123',
      'frequency': 'Monthly',
      'avatarUrl': '',
    },
    {
      'name': 'Jane Doe',
      'subtitle': '0xABC…123',
      'amount': '+\$200',
      'frequency': 'Bi‑Weekly',
      'avatarUrl': '',
    },
    // … add more …
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        // make the stack fill the screen:
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

          // main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payroll',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      glassHistoryIcon(onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Summary Cards ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SummaryGlassCard(
                          title: 'Total Payroll',
                          value: '₱12,340',
                          padding: const EdgeInsets.all(10),
                          valueStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryGlassCard(
                          title: 'Next Payroll Due',
                          value: '26 August 2025',
                          padding: const EdgeInsets.all(10),
                          valueStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Action Buttons ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {}, // TODO: add employee
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5B50FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '+ Add Employee',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {}, // TODO: send payroll
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B50FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Send Payroll Now'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Employees Header ────────────────────
                  Row(
                    children: const [
                      Text(
                        'Employees',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.white54),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ─── Scrollable List ─────────────────────
                  Expanded(
                    child: ListView.separated(
                      itemCount: _employees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final e = _employees[i];
                        return PayrollItemwidget(
                          avatarUrl: e['avatarUrl']!,
                          name: e['name']!,
                          subtitle: e['subtitle']!,
                          amount: e['amount']!,
                          frequency: e['frequency']!,
                          onTap: () {
                            // optional: navigate to employee detail…
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

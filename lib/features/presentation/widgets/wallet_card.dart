import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'glass_card.dart';

class WalletCard extends StatelessWidget {
  final String balance;
  final String convertedAmount;
  final String currency;
  final VoidCallback? onCurrencyTap;
  final VoidCallback? onConnectTap;    // ← new

  const WalletCard({
    super.key,
    required this.balance,
    required this.convertedAmount,
    required this.currency,
    this.onCurrencyTap,
    this.onConnectTap,                // ← new
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 200, // bumped to make room for the button
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row (wallet info)
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Wallet",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          MdiIcons.ethereum,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          balance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Converted row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Converted to",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      convertedAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onCurrencyTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Text(
                          currency,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ← new “Connect Wallet” button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onConnectTap,
                child: const Text(
                  'Connect Wallet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

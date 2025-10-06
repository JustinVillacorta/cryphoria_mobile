import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/manager_connect_wallet_bottom_sheet.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_ViewModel/home_Viewmodel.dart';

class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({super.key});

  @override
  ConsumerState<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends ConsumerState<WalletCard> {
  bool _showUSD = false; // Toggle between PHP and USD

  void _copyAddressToClipboard(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallet address copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDisconnectConfirmationDialog(BuildContext context, WalletNotifier notifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disconnect Wallet'),
          content: const Text(
            'Are you sure you want to disconnect your wallet? You will need to reconnect it to access your funds.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      try {
        debugPrint('🔍 Manager UI - Starting disconnect from confirmation dialog');
        await notifier.disconnectWallet();
        debugPrint('🔍 Manager UI - Disconnect completed, checking state');

        if (mounted) {
          // Wait a bit to ensure state is updated
          await Future.delayed(const Duration(milliseconds: 100));

          final updated = ref.read(walletNotifierProvider);
          debugPrint('🔍 Manager UI - State after disconnect: wallet=${updated.wallet?.address}');

          if (updated.error != null && updated.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to disconnect: ${updated.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wallet disconnected successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Manager UI - Disconnect error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to disconnect: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showConnectWalletBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ManagerConnectWalletBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final state = ref.watch(walletNotifierProvider);
    final notifier = ref.read(walletNotifierProvider.notifier);

    debugPrint('🔍 Manager UI - Building with wallet: ${state.wallet?.address}');

    if (state.isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5FBF), Color(0xFF6B46C1)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.error != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5FBF), Color(0xFF6B46C1)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error: ${state.error}',
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: notifier.clearError,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: screenHeight * 0.018),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.03,
        screenWidth * 0.05,
        screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5FBF), Color(0xFF6B46C1)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: state.wallet != null
          ? _buildConnectedWalletView(screenWidth, screenHeight, state, notifier)
          : _buildNoWalletView(screenWidth, screenHeight),
    );
  }

  Widget _buildNoWalletView(double screenWidth, double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: screenWidth * 0.08,
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        Text(
          'No Wallet Connected',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          'Connect your wallet to view your balance.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: screenWidth * 0.035,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.03),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showConnectWalletBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
              elevation: 0,
            ),
            child: Text(
              'Connect Wallet',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedWalletView(
      double screenWidth,
      double screenHeight,
      WalletState state,
      WalletNotifier notifier,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Current Wallet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.035,
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) async {
                if (state.isLoading) return;

                switch (value) {
                  case 'refresh':
                    await notifier.refreshWallet();
                    final updated = ref.read(walletNotifierProvider);
                    if (mounted && updated.error != null && updated.error!.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to refresh: ${updated.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wallet balance refreshed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    break;
                  case 'switch':
                    _showConnectWalletBottomSheet(context);
                    break;
                  case 'disconnect':
                    await _showDisconnectConfirmationDialog(context, notifier);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.black87),
                      SizedBox(width: 12),
                      Text('Refresh Balance'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'switch',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.black87),
                      SizedBox(width: 12),
                      Text('Switch Wallet'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'disconnect',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Disconnect Wallet', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          state.wallet!.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => _copyAddressToClipboard(context, state.wallet!.address),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.001,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.wallet!.displayAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.8),
                  size: screenWidth * 0.035,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.001),
        const SizedBox(height: 8),
        Text(
          '${state.wallet!.balance.toStringAsFixed(6)} ETH',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Converted to ${_showUSD ? 'USD' : 'PHP'}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _showUSD
                      ? '\$${state.wallet!.balanceInUSD.toStringAsFixed(2)}'
                      : '₱${state.wallet!.balanceInPHP.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: DropdownButton<String>(
                value: _showUSD ? 'USD' : 'PHP',
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                isDense: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _showUSD = newValue == 'USD';
                    });
                  }
                },
                items: ['PHP', 'USD'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_ViewModel/home_Viewmodel.dart';

class WalletCard extends StatefulWidget {
  const WalletCard({super.key});
  
  @override
  _WalletCardState createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _showUSD = false; // Toggle between PHP and USD

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (viewModel.error != null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error: ${viewModel.error}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => viewModel.clearError(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Wallet',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      if (viewModel.wallet != null) ...[
                        Text(
                          viewModel.wallet!.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (viewModel.wallet!.address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            viewModel.wallet!.displayAddress,
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ],
                    ],
                  ),
                  if (viewModel.wallet != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        viewModel.wallet!.walletType,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text('ETH', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.wallet != null 
                    ? '${viewModel.wallet!.balance.toStringAsFixed(6)} ETH' 
                    : 'No Wallet Connected',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Converted to ${_showUSD ? 'USD' : 'PHP'}', 
                    style: const TextStyle(color: Colors.white70, fontSize: 12)
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showUSD = !_showUSD),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _showUSD ? 'USD' : 'PHP',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                viewModel.wallet != null 
                    ? (_showUSD 
                        ? '\$${viewModel.wallet!.balanceInUSD.toStringAsFixed(2)}'
                        : '₱${viewModel.wallet!.balanceInPHP.toStringAsFixed(2)}')
                    : (_showUSD ? '\$0.00' : '₱0.00'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _showWalletOptionsDialog(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(viewModel.wallet != null ? 'Wallet Options' : 'Connect Wallet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showWalletOptionsDialog(BuildContext context, WalletViewModel viewModel) async {
    if (viewModel.wallet == null) {
      // No wallet connected, show connect dialog
      return _showConnectWalletDialog(context, viewModel);
    }

    // Wallet is connected, show options
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Wallet Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh Balance'),
                subtitle: Text('Update ETH balance and PHP conversion'),
                onTap: () => Navigator.pop(context, 'refresh'),
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('Switch Wallet'),
                subtitle: Text('Connect a different wallet'),
                onTap: () => Navigator.pop(context, 'switch'),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Disconnect Wallet'),
                subtitle: Text('Remove wallet connection'),
                onTap: () => Navigator.pop(context, 'disconnect'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      switch (result) {
        case 'refresh':
          await viewModel.refreshWallet();
          if (mounted) {
            if (viewModel.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to refresh: ${viewModel.error}')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wallet balance refreshed')),
              );
            }
          }
          break;
        case 'switch':
          if (mounted) {
            await _showConnectWalletDialog(context, viewModel);
          }
          break;
        case 'disconnect':
          await viewModel.disconnectWallet();
          if (mounted) {
            if (viewModel.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to disconnect: ${viewModel.error}')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wallet disconnected')),
              );
            }
          }
          break;
      }
    }
  }

  Future<void> _showConnectWalletDialog(BuildContext context, WalletViewModel viewModel) async {
    final controller = TextEditingController();
    String selectedWallet = 'MetaMask';

    final shouldConnect = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter private key'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Private key'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: selectedWallet,
                    items: const [
                      DropdownMenuItem(value: 'MetaMask', child: Text('MetaMask')),
                      DropdownMenuItem(value: 'Trust Wallet', child: Text('Trust Wallet')),
                      DropdownMenuItem(value: 'Coinbase', child: Text('Coinbase')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedWallet = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Connect'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldConnect == true) {
      // Check if widget is still mounted before proceeding
      if (!mounted) return;
      
      // Check if wallet is already connected with same private key
      if (viewModel.wallet != null && 
          viewModel.wallet!.private_key == controller.text) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallet already connected!')),
          );
        }
        return;
      }
      
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Connecting wallet...'),
              ],
            ),
          ),
        );
      }
      
      try {
        String endpoint;
        switch (selectedWallet) {
          case 'MetaMask':
            endpoint = 'connect_metamask/';
            break;
          case 'Coinbase':
            endpoint = 'connect_coinbase/';
            break;
          case 'Trust Wallet':
          default:
            endpoint = 'connect_trust_wallet/';
        }
        
        await viewModel.connect(
          controller.text,
          endpoint: endpoint,
          walletName: selectedWallet,
          walletType: selectedWallet,
        );
        
        // Always dismiss loading dialog first if widget is still mounted
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        
        // Check if connection was successful and widget is still mounted
        if (mounted) {
          if (viewModel.wallet != null && viewModel.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Wallet connected successfully!')),
            );
          } else if (viewModel.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to connect: ${viewModel.error}')),
            );
          }
        }
      } catch (e) {
        // Always dismiss loading dialog first if widget is still mounted
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        
        // Show error message if widget is still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect wallet: $e')),
          );
        }
      }
    }
  }
}
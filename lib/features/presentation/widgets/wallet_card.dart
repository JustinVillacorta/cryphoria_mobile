import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_viewmodel/home_viewmodel.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

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
              const Text(
                'Current Wallet',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
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
                viewModel.wallet != null ? '${viewModel.wallet!.balance} ETH' : 'No Wallet Connected',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Converted to', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 2),
              const Text('12,230 PHP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _showConnectWalletDialog(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Connect Wallet'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect wallet')),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
  }
}
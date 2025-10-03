import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Unused import removed
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';

class ConnectPrivateKeyBottomSheet extends ConsumerStatefulWidget {
  const ConnectPrivateKeyBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectPrivateKeyBottomSheet> createState() => _ConnectPrivateKeyBottomSheetState();
}

class _ConnectPrivateKeyBottomSheetState extends ConsumerState<ConnectPrivateKeyBottomSheet> {
  final TextEditingController _privateKeyController = TextEditingController();
  bool _isValidFormat = true;
  bool _isLoading = false;
  String _selectedWallet = 'MetaMask';
  final List<String> _wallets = ['MetaMask', 'Trust Wallet', 'Coinbase'];

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  void _validatePrivateKey(String value) {
    setState(() {
      _isValidFormat = value.isEmpty ||
          (value.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(value)) ||
          (value.startsWith('0x') && value.length == 66 && RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(value));
    });
  }

  void _connect() async {
    if (_privateKeyController.text.isEmpty || !_isValidFormat) {
      setState(() {
        _isValidFormat = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(homeEmployeeNotifierProvider.notifier);
    try {
      await notifier.connect(
        _privateKeyController.text,
        walletName: _selectedWallet,
        walletType: _selectedWallet,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        final state = ref.read(homeEmployeeNotifierProvider);
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect: ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.wallet != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet connected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Force refresh to ensure balance is fetched
          await notifier.refreshWallet();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Connect with Private Key',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enter your private key below to connect your wallet to Cryphoria.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Wallet Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedWallet,
              isExpanded: true,
              items: _wallets.map((wallet) => DropdownMenuItem(
                value: wallet,
                child: Text(wallet),
              )).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() => _selectedWallet = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter Private Key',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isValidFormat ? Colors.red : Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _privateKeyController,
                onChanged: _validatePrivateKey,
                decoration: InputDecoration(
                  hintText: 'Enter your private key',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 1,
                style: const TextStyle(fontSize: 14),
                enabled: !_isLoading,
              ),
            ),
            if (!_isValidFormat) ...[
              const SizedBox(height: 8),
              const Text(
                'Invalid private key format',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Warning',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Never share your private key with anyone. This information is critical to your wallet access and should be kept secure.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading || !_isValidFormat ? null : _connect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF9747FF),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Connect Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cryphoria_mobile/features/presentation/widgets/connect_wallet_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';

class EmployeeWalletCardWidget extends StatefulWidget {
  final bool isTablet;
  final VoidCallback? onWhatIsCryptoWallet;

  const EmployeeWalletCardWidget({
    Key? key,
    this.isTablet = false,
    this.onWhatIsCryptoWallet,
  }) : super(key: key);

  @override
  State<EmployeeWalletCardWidget> createState() => _EmployeeWalletCardWidgetState();
}

class _EmployeeWalletCardWidgetState extends State<EmployeeWalletCardWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<HomeEmployeeViewModel>(context);

    if (viewModel.isLoading) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: widget.isTablet ? 500 : double.infinity),
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

    if (viewModel.errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: widget.isTablet ? 500 : double.infinity),
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
              'Error: ${viewModel.errorMessage}',
              style: TextStyle(color: Colors.white, fontSize: widget.isTablet ? 16 : screenWidth * 0.035),
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: screenHeight * 0.018),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: widget.isTablet ? 16 : screenWidth * 0.04),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: widget.isTablet ? 500 : double.infinity),
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
      child: viewModel.wallet != null
          ? _buildConnectedWalletView(screenWidth, screenHeight, viewModel)
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
            size: widget.isTablet ? 32 : screenWidth * 0.08,
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        Text(
          'No Wallet Connected',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isTablet ? 24 : screenWidth * 0.055,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          'Connect your wallet to view your balance.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: widget.isTablet ? 14 : screenWidth * 0.035,
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
                side: BorderSide(color: Colors.white, width: 2),
              ),
              elevation: 0,
            ),
            child: Text(
              'Connect Wallet',
              style: TextStyle(
                fontSize: widget.isTablet ? 16 : screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        GestureDetector(
          onTap: widget.onWhatIsCryptoWallet,
          child: Text(
            'What is a crypto wallet?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: widget.isTablet ? 12 : screenWidth * 0.032,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedWalletView(double screenWidth, double screenHeight, HomeEmployeeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Current Wallet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: widget.isTablet ? 16 : screenWidth * 0.035,
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) async {
                switch (value) {
                  case 'refresh':
                    await viewModel.refreshWallet();
                    if (mounted && viewModel.errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to refresh: ${viewModel.errorMessage}')),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet balance refreshed')),
                      );
                    }
                    break;
                  case 'switch':
                    await _showConnectWalletBottomSheet(context);
                    break;
                  case 'disconnect':
                    await viewModel.disconnectWallet();
                    if (mounted && viewModel.errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to disconnect: ${viewModel.errorMessage}')),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet disconnected')),
                      );
                    }
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
          viewModel.wallet!.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isTablet ? 18 : screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
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
                viewModel.wallet!.displayAddress,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isTablet ? 18 : screenWidth * 0.04,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(width: screenWidth * 0.015),
              GestureDetector(
                onTap: () {
                  // Implement copy to clipboard (e.g., using package:clipboard)
                  debugPrint('Copying wallet address: ${viewModel.wallet!.address}');
                },
                child: Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.8),
                  size: widget.isTablet ? 16 : screenWidth * 0.035,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.001),
        const SizedBox(height: 8),
        Text(
          '${viewModel.wallet!.balance.toStringAsFixed(6)} ETH',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isTablet ? 36 : screenWidth * 0.08,
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
                  'Converted to ${viewModel.selectedCurrency}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: widget.isTablet ? 12 : screenWidth * 0.03,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  viewModel.selectedCurrency == 'USD'
                      ? '\$${viewModel.wallet!.balanceInUSD.toStringAsFixed(2)}'
                      : '₱${viewModel.wallet!.balanceInPHP.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isTablet ? 16 : screenWidth * 0.035,
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
                value: viewModel.selectedCurrency,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                isDense: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isTablet ? 12 : screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    viewModel.changeCurrency(newValue);
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

  Future<void> _showConnectWalletBottomSheet(BuildContext context) async {
    final controller = TextEditingController();
    String selectedWallet = 'MetaMask';
    final viewModel = Provider.of<HomeEmployeeViewModel>(context, listen: false);
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ConnectPrivateKeyBottomSheet(),
    );

    if (result != null && mounted) {
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
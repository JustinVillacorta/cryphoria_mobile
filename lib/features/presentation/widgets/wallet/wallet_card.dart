import 'package:cryphoria_mobile/features/presentation/manager/HomeManager/ViewModels/home_manager_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet/manager_connect_wallet_bottom_sheet.dart';


class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({super.key});

  @override
  ConsumerState<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends ConsumerState<WalletCard> with SingleTickerProviderStateMixin {
  bool _showUSD = false;
  int _currentCardIndex = 0;
  double _dragOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _cardBackgrounds = [
    'assets/images/wallet_bg.png',
    'assets/images/wallet_bg2.png',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(-150.0, 150.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    const swipeThreshold = 80.0;

    if (_dragOffset > swipeThreshold) {
      _switchCard(-1);
    } else if (_dragOffset < -swipeThreshold) {
      _switchCard(1);
    } else {
      _animateBackToPosition(0.0);
    }
  }

  void _switchCard(int direction) {
    setState(() {
      _currentCardIndex = (_currentCardIndex + direction) % _cardBackgrounds.length;
      if (_currentCardIndex < 0) {
        _currentCardIndex = _cardBackgrounds.length - 1;
      }
    });
    _animateBackToPosition(0.0);
  }

  void _animateBackToPosition(double target) {
    _animation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0.0);
  }

  void _copyAddressToClipboard(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallet address copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSwitchWalletConfirmationDialog(BuildContext context, WalletNotifier notifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch Wallet'),
          content: const Text(
            'This will disconnect your current wallet and allow you to connect a different one. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Switch'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      try {
        debugPrint('🔍 Manager UI - Starting switch wallet from confirmation dialog');
        await notifier.switchWallet();
        debugPrint('🔍 Manager UI - Switch wallet completed, checking state');

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          if (!context.mounted) return;

          final updated = ref.read(walletNotifierProvider);
          debugPrint('🔍 Manager UI - State after switch: wallet=${updated.wallet?.address}');

          if (updated.error != null && updated.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to switch wallet: ${updated.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wallet disconnected. You can now connect a new wallet.'),
                backgroundColor: Colors.blue,
              ),
            );
            _showConnectWalletBottomSheet(context);
          }
        }
      } catch (e) {
        debugPrint('❌ Manager UI - Switch wallet error: $e');
        if (!mounted) return;
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          if (!context.mounted) return;

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
        if (!mounted) return;
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      return _buildSingleCard(
        screenWidth,
        screenHeight,
        _cardBackgrounds[_currentCardIndex],
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.error != null) {
      return _buildSingleCard(
        screenWidth,
        screenHeight,
        _cardBackgrounds[_currentCardIndex],
        Column(
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
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
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

    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Opacity(
              opacity: 0.5,
              child: _buildCard(
                screenWidth,
                screenHeight,
                _cardBackgrounds[(_currentCardIndex + 1) % _cardBackgrounds.length],
                state,
                notifier,
                isInteractive: false,
              ),
            ),
          ),
          Positioned(
            top: _dragOffset * 0.2,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Transform.rotate(
                angle: _dragOffset * 0.0005,
                child: _buildCard(
                  screenWidth,
                  screenHeight,
                  _cardBackgrounds[_currentCardIndex],
                  state,
                  notifier,
                  isInteractive: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCard(double screenWidth, double screenHeight, String background, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildCard(
      double screenWidth,
      double screenHeight,
      String background,
      WalletState state,
      WalletNotifier notifier, {
        required bool isInteractive,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.03,
        screenWidth * 0.05,
        screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: state.wallet != null
          ? _buildConnectedWalletView(screenWidth, screenHeight, state, notifier, isInteractive)
          : _buildNoWalletView(screenWidth, screenHeight, isInteractive),
    );
  }

  Widget _buildNoWalletView(double screenWidth, double screenHeight, bool isInteractive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
            if (isInteractive)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) async {
                  if (value == 'connect') {
                    _showConnectWalletBottomSheet(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'connect',
                    child: Row(
                      children: [
                        Icon(Icons.link, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Connect Wallet'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 4),
        Text(
          'No Wallet Connected',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '0.000000 ETH',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
                  _showUSD ? '\$0.00' : '₱0.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (isInteractive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _showUSD ? 'USD' : 'PHP',
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  isDense: true,
                  selectedItemBuilder: (BuildContext context) {
                    return ['PHP', 'USD'].map<Widget>((String item) {
                      return Text(
                        item,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList();
                  },
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

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildConnectedWalletView(
      double screenWidth,
      double screenHeight,
      WalletState state,
      WalletNotifier notifier,
      bool isInteractive,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
            if (isInteractive)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) async {
                  if (state.isLoading) return;

                  switch (value) {
                    case 'refresh':
                      if (!mounted) return;

                      await notifier.refreshWallet();

                      if (!mounted) return;

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
                      await _showSwitchWalletConfirmationDialog(context, notifier);
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
          'Metamask',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isInteractive)
          GestureDetector(
            onTap: () => _copyAddressToClipboard(context, state.wallet!.address),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.005,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
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
                    color: Colors.white.withValues(alpha: 0.8),
                    size: screenWidth * 0.035,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Text(
              state.wallet!.displayAddress,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.normal,
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
            if (isInteractive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _showUSD ? 'USD' : 'PHP',
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  isDense: true,
                  selectedItemBuilder: (BuildContext context) {
                    return ['PHP', 'USD'].map<Widget>((String item) {
                      return Text(
                        item,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList();
                  },
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet/wallet_card.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/manager_home_skeleton.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/buttons/quick_actions.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/recent_transactions.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final walletService = ref.read(walletServiceProvider);
      final walletState = ref.read(walletNotifierProvider);
      
      // Only reconnect if wallet is not already connected (prevents unnecessary refreshes)
      if (await walletService.hasStoredWallet() && walletState.wallet == null) {
        await ref.read(walletNotifierProvider.notifier).reconnect();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
    final walletNotifier = ref.read(walletNotifierProvider.notifier);
    final user = ref.watch(userProvider);
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1024;
    final double appBarHeight = isDesktop ? 96 : (isTablet ? 88 : 72);
    final double headerHPad = isDesktop ? 28 : (isTablet ? 24 : 20);
    final double headerVPad = isDesktop ? 14 : (isTablet ? 12 : 10);
    final double avatarRadius = isDesktop ? 24 : (isTablet ? 22 : 20);
    final double titleFont = isDesktop ? 18 : (isTablet ? 17 : 16);
    final double subtitleFont = isDesktop ? 15 : (isTablet ? 14 : 13);
    final double listHPad = isDesktop ? 32 : (isTablet ? 24 : 16);
    final double listTPad = isDesktop ? 24 : 16;
    final double sectionGap = isDesktop ? 28 : 24;
    final double contentMaxWidth = isDesktop ? 1200 : (isTablet ? 900 : double.infinity);
    String displayName = (() {
      final parts = <String>[];
      if ((user?.firstName ?? '').trim().isNotEmpty) parts.add(user!.firstName.trim());
      if ((user?.lastName ?? '').trim().isNotEmpty) parts.add(user!.lastName!.trim());
      return parts.isNotEmpty ? parts.join(' ') : 'User';
    })();

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: headerHPad, vertical: headerVPad),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hi, $displayName',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'How are you today?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: subtitleFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => walletNotifier.refresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            if (walletState.isLoading) {
              return const ManagerHomeSkeleton();
            }
            if (walletState.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(walletState.error!)),
                );
                walletNotifier.clearError();
              });
            }
            final bottomInset = MediaQuery.of(context).padding.bottom + 50;
            final isWide = isTablet || isDesktop;
            if (!isWide) {
              // Mobile: vertical stack
              return ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  listHPad,
                  listTPad,
                  listHPad,
                  bottomInset,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const WalletCard(),
                  QuickActions(
                    onPaymentSuccess: () {
                      walletNotifier.refreshTransactions();
                    },
                  ),
                  SizedBox(height: sectionGap),
                  const RecentTransactions(),
                ],
              );
            }

            // Tablet/Desktop: wider layout
            final double maxW = contentMaxWidth;
            final double gap = 16;
            final double leftW = (maxW - gap) * 0.62;
            final double rightW = (maxW - gap) * 0.38;

            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                listHPad,
                listTPad,
                listHPad,
                bottomInset,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: leftW,
                          child: const WalletCard(),
                        ),
                        SizedBox(
                          width: rightW,
                          child: QuickActions(
                            onPaymentSuccess: () {
                              walletNotifier.refreshTransactions();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sectionGap),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: const RecentTransactions(),
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}

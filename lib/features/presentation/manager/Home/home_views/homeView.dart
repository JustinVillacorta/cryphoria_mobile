import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet_card.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/manager_home_skeleton.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/quick_actions.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/crypto_news_strip.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/recent_transactions.dart';

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
      if (await walletService.hasStoredWallet()) {
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
    final String displayName = (() {
      final parts = <String>[];
      if ((user?.firstName ?? '').trim().isNotEmpty) parts.add(user!.firstName!.trim());
      if ((user?.lastName ?? '').trim().isNotEmpty) parts.add(user!.lastName!.trim());
      return parts.isNotEmpty ? parts.join(' ') : 'User';
    })();

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
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
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'How are you today?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                      onPressed: () {},
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
            return ListView(
              controller: _scrollController,
              // Add extra bottom padding (including safe-area inset) so the last items can be fully scrolled into view.
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 50,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const WalletCard(),
                QuickActions(
                  onPaymentSuccess: () {
                    walletNotifier.refreshTransactions();
                  },
                ),
                const SizedBox(height: 16),
                const CryptoNewsSection(),
                const SizedBox(height: 24),
                const RecentTransactions(),
                // RevenueChart removed from home view per request
              ],
            );
          },
        ),
      );
  }
}

import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/dependency_injection/app_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/wallet_card.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/quick_actions.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/recent_transactions.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/revenue_chart.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await sl<WalletService>().hasStoredWallet()) {
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hi, Juan',
                            style: TextStyle(
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
              return const Center(child: CircularProgressIndicator());
            }
            if (walletState.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(walletState.error!)),
                );
                walletNotifier.clearError();
              });
            }
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WalletCard(),
                  const SizedBox(height: 24),
                  QuickActions(
                    onPaymentSuccess: () {
                      walletNotifier.refreshTransactions();
                    },
                  ),
                  const SizedBox(height: 24),
                  const RecentTransactions(),
                  const SizedBox(height: 24),
                  const RevenueChart(),
                ],
              ),
            );
          },
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final size = MediaQuery.of(context).size;
    final walletState = ref.watch(walletNotifierProvider);
    final walletNotifier = ref.read(walletNotifierProvider.notifier);
    final user = ref.watch(userProvider);

    final bool isSmallScreen = size.height < 700;
    final bool isTablet = size.width >= 600 && size.width < 1024;
    final bool isDesktop = size.width >= 1024;

    final double appBarHeight = isDesktop ? 96 : isTablet ? 88 : 72;
    final double horizontalPadding = isDesktop ? 32 : isTablet ? 24 : 20;
    final double verticalPadding = isDesktop ? 24 : 16;
    final double avatarRadius = isDesktop ? 26 : isTablet ? 24 : 22;
    final double titleFontSize = isDesktop ? 20 : isTablet ? 18 : 17;
    final double subtitleFontSize = isDesktop ? 15 : isTablet ? 14 : 13;
    final double sectionGap = isDesktop ? 28 : isTablet ? 24 : 20;
    final double contentMaxWidth = isDesktop ? 1200 : isTablet ? 900 : double.infinity;

    String displayName = (() {
      final parts = <String>[];
      if ((user?.firstName ?? '').trim().isNotEmpty) parts.add(user!.firstName.trim());
      if ((user?.lastName ?? '').trim().isNotEmpty) parts.add(user!.lastName!.trim());
      return parts.isNotEmpty ? parts.join(' ') : 'User';
    })();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding * 0.6,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF9747FF).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: const Color(0xFF9747FF),
                        size: avatarRadius * 0.9,
                      ),
                    ),
                  ),
                  SizedBox(width: isDesktop ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hi, $displayName',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A1A1A),
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        Text(
                          'How are you today?',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B6B6B),
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9747FF)),
                      onPressed: () => walletNotifier.refresh(),
                      tooltip: 'Refresh',
                    ),
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
                SnackBar(
                  content: Text(
                    walletState.error!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              walletNotifier.clearError();
            });
          }

          final bottomInset = MediaQuery.of(context).padding.bottom + 60;
          final isWide = isTablet || isDesktop;

          if (!isWide) {
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
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

          final double gap = 16;
          final double leftW = (contentMaxWidth - gap) * 0.62;
          final double rightW = (contentMaxWidth - gap) * 0.38;

          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              bottomInset,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
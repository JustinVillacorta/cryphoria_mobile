
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../widgets/payslip/payslip_list_item.dart';
import '../../../widgets/payslip/payslip_filter_widget.dart';
import 'payslip_details_view.dart';

class PayslipListView extends ConsumerStatefulWidget {
  const PayslipListView({super.key});

  @override
  ConsumerState<PayslipListView> createState() => _PayslipListViewState();
}

class _PayslipListViewState extends ConsumerState<PayslipListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(payslipListViewModelProvider.notifier).loadPayslips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(payslipListViewModelProvider);
    final viewModel = ref.read(payslipListViewModelProvider.notifier);

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Payslips',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF9747FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_outlined,
              color: Colors.white,
              size: isTablet ? 24 : 22,
            ),
            onPressed: () => viewModel.refreshPayslips(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
            child: PayslipFilterWidget(
              currentFilter: state.currentFilter,
              onFilterChanged: (filter) => viewModel.updateFilter(filter),
            ),
          ),

          Expanded(
            child: _buildContent(state, viewModel, isTablet, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, viewModel, bool isTablet, bool isDesktop) {
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1200.0 : isTablet ? 900.0 : double.infinity;

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
              strokeWidth: 2.5,
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              'Loading payslips...',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 16 : 15,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isTablet ? 64 : 56,
                color: Colors.red.shade400,
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                'Error loading payslips',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Text(
                state.error!,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.red.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 28 : 24),
              ElevatedButton(
                onPressed: () => viewModel.refreshPayslips(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 24,
                    vertical: isTablet ? 14 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.payslips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: isTablet ? 64 : 56,
              color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              'No payslips found',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                'Payslips will appear here once they are generated',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshPayslips(),
      color: const Color(0xFF9747FF),
      strokeWidth: 2.5,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: ListView.separated(
            padding: EdgeInsets.all(horizontalPadding),
            itemCount: state.payslips.length,
            separatorBuilder: (context, index) => SizedBox(height: isTablet ? 14 : 12),
            itemBuilder: (context, index) {
              final payslip = state.payslips[index];
              return PayslipListItem(
                payslip: payslip,
                onTap: () => _navigateToDetails(payslip),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(Payslip payslip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayslipDetailsView(payslip: payslip),
      ),
    );
  }
}
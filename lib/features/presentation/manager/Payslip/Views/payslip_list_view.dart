// lib/features/presentation/manager/Payslip/Views/payslip_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../../domain/entities/payslip.dart';
import '../Widgets/payslip_list_item.dart';
import '../Widgets/payslip_filter_widget.dart';
import 'payslip_details_view.dart';

class PayslipListView extends ConsumerStatefulWidget {
  const PayslipListView({Key? key}) : super(key: key);

  @override
  ConsumerState<PayslipListView> createState() => _PayslipListViewState();
}

class _PayslipListViewState extends ConsumerState<PayslipListView> {
  @override
  void initState() {
    super.initState();
    // Load payslips on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(payslipListViewModelProvider.notifier).loadPayslips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(payslipListViewModelProvider);
    final viewModel = ref.read(payslipListViewModelProvider.notifier);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Payslips',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF9747FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => viewModel.refreshPayslips(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: PayslipFilterWidget(
              currentFilter: state.currentFilter,
              onFilterChanged: (filter) => viewModel.updateFilter(filter),
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(state, viewModel, screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, viewModel, double screenWidth, double screenHeight) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading payslips...',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.15,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Error loading payslips',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshPayslips(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9747FF),
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
              size: screenWidth * 0.15,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'No payslips found',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Payslips will appear here once they are generated',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshPayslips(),
      color: Color(0xFF9747FF),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: state.payslips.length,
        itemBuilder: (context, index) {
          final payslip = state.payslips[index];
          return PayslipListItem(
            payslip: payslip,
            onTap: () => _navigateToDetails(payslip),
          );
        },
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
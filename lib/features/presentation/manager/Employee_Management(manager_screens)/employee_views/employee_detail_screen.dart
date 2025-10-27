import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/payslip.dart' as payslip_entity;
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../Payslip/Views/payslip_details_view.dart';
import 'employee_payslip_list_view.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  List<payslip_entity.Payslip> employeePayslips = [];
  bool isLoadingPayslips = true;
  String? payslipError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    Future.microtask(() => _loadEmployeePayslips());
  }

  Future<void> _loadEmployeePayslips() async {
    try {
      setState(() {
        isLoadingPayslips = true;
        payslipError = null;
      });

      final payslipRepository = ref.read(payslipRepositoryProvider);
      final payslips = await payslipRepository.getUserPayslips(
        employeeId: widget.employee.userId,
      );

      if (mounted) {
        setState(() {
          employeePayslips = payslips;
          isLoadingPayslips = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          payslipError = 'Failed to load payslips: ${e.toString()}';
          isLoadingPayslips = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildEmployeeHeader(isSmallScreen, isTablet, isDesktop),
          _buildTabNavigation(isSmallScreen, isTablet),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(isSmallScreen, isTablet, isDesktop),
                    _buildPayrollTab(isSmallScreen, isTablet, isDesktop),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final titleSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final nameSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final positionSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final detailSize = isDesktop ? 14.0 : isTablet ? 13.5 : 13.0;
    final avatarRadius = isDesktop ? 40.0 : isTablet ? 36.0 : 32.0;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;

    final hasValidImage = widget.employee.profileImage != null && 
                          widget.employee.profileImage!.isNotEmpty &&
                          Uri.tryParse(widget.employee.profileImage!)?.hasAbsolutePath == true;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9747FF), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isSmallScreen ? 8 : 12,
            horizontalPadding,
            isSmallScreen ? 16 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isTablet ? 26 : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    'Employee Details',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: isTablet ? 24 : 22,
                        ),
                        onPressed: () => _showDeleteDialog(isSmallScreen, isTablet),
                        tooltip: 'Remove Employee',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: isTablet ? 24 : 22,
                        ),
                        onPressed: () => _editEmployee(),
                        tooltip: 'Edit Employee',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.white,
                      backgroundImage: hasValidImage
                          ? NetworkImage(widget.employee.profileImage!)
                          : null,
                      child: !hasValidImage
                          ? Icon(
                              Icons.person_outline,
                              size: avatarRadius * 0.85,
                              color: const Color(0xFF9747FF),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: isTablet ? 18 : 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.employee.displayName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: nameSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 10,
                                vertical: isTablet ? 6 : 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.green.shade400,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.inter(
                                  color: Colors.green.shade100,
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          widget.employee.position ?? 'Employee',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: positionSize,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.employee.employeeCode,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: detailSize,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 14 : 18),

              Wrap(
                spacing: isTablet ? 24 : 20,
                runSpacing: isSmallScreen ? 8 : 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: isTablet ? 18 : 16,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Flexible(
                        child: Text(
                          widget.employee.email,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: detailSize,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: isTablet ? 18 : 16,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        widget.employee.department ?? 'General',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: detailSize,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation(bool isSmallScreen, bool isTablet) {
    final fontSize = isTablet ? 16.0 : 15.0;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem('Details', 0, isSmallScreen, isTablet, fontSize),
          _buildTabItem('Payroll', 1, isSmallScreen, isTablet, fontSize),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, bool isSmallScreen, bool isTablet, double fontSize) {
    bool isActive = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF9747FF) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isActive ? const Color(0xFF9747FF) : const Color(0xFF6B6B6B),
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final gap = isSmallScreen ? 16.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPersonalInformationCard(isSmallScreen, isTablet, isDesktop),
          SizedBox(height: gap),
          _buildEmploymentInformationCard(isSmallScreen, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationCard(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return _buildCard(
      icon: Icons.person_outline,
      title: 'Personal Information',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        _buildInfoRow('Email', widget.employee.email, isSmallScreen, isTablet),
        _buildInfoRow('Username', widget.employee.username, isSmallScreen, isTablet),
        _buildInfoRow('Employee ID', widget.employee.userId, isSmallScreen, isTablet),
        _buildInfoRow('Role', widget.employee.role, isSmallScreen, isTablet),
        _buildInfoRow('Status', widget.employee.isActive ? 'Active' : 'Inactive', isSmallScreen, isTablet),
        _buildInfoRow('Joined Date', widget.employee.createdAt.toString().split(' ')[0], isSmallScreen, isTablet, isLast: true),
      ],
    );
  }

  Widget _buildEmploymentInformationCard(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return _buildCard(
      icon: Icons.work_outline,
      title: 'Employment Information',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        _buildInfoRow('Department', widget.employee.department ?? 'General', isSmallScreen, isTablet),
        _buildInfoRow('Position', widget.employee.position ?? 'Employee', isSmallScreen, isTablet, isLast: true),
      ],
    );
  }

  Widget _buildPayrollTab(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final gap = isSmallScreen ? 16.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPayslipSummaryCard(isSmallScreen, isTablet, isDesktop),
          SizedBox(height: gap),
          _buildPayslipHistoryCard(isSmallScreen, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildPayslipSummaryCard(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final latestPayslip = employeePayslips.isNotEmpty ? employeePayslips.first : null;
    final totalPayslips = employeePayslips.length;
    final totalPaid = employeePayslips
        .where((p) => p.status == 'paid')
        .fold(0.0, (sum, payslip) => sum + payslip.finalNetPay);

    final amountSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final labelSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final _ = amountSize;

    return _buildCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Payslip Summary',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        if (latestPayslip != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${latestPayslip.finalNetPay.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              Text(
                'Latest Net Pay',
                style: GoogleFonts.inter(
                  fontSize: labelSize,
                  color: const Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          _buildPayrollDetailRow(
            'Base Salary',
            '\$${latestPayslip.baseSalary.toStringAsFixed(2)}',
            isSmallScreen,
            isTablet,
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Row(
            children: [
              Expanded(
                child: _buildPayrollDetailColumn(
                  'Total Deductions',
                  '\$${latestPayslip.totalDeductions.toStringAsFixed(2)}',
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: _buildPayrollDetailColumn(
                  'Net Pay',
                  '\$${latestPayslip.netAmount.toStringAsFixed(2)}',
                  isSmallScreen,
                  isTablet,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
          SizedBox(height: isSmallScreen ? 18 : 22),
          Text(
            'Deduction Breakdown',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 17 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 14),
          _buildDeductionRow('Tax', '\$${latestPayslip.taxDeduction.toStringAsFixed(2)}', isSmallScreen, isTablet),
          _buildDeductionRow('Insurance', '\$${latestPayslip.insuranceDeduction.toStringAsFixed(2)}', isSmallScreen, isTablet),
          _buildDeductionRow('Retirement', '\$${latestPayslip.retirementDeduction.toStringAsFixed(2)}', isSmallScreen, isTablet),
          _buildDeductionRow('Others', '\$${latestPayslip.otherDeductions.toStringAsFixed(2)}', isSmallScreen, isTablet),
        ] else ...[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 40 : 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: isTablet ? 64 : 56,
                    color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    'No payslips found',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 18 : 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B6B6B),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  Text(
                    'Payslips will appear here once generated',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 15 : 14,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: isSmallScreen ? 18 : 22),
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalPayslips',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 24 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Total Payslips',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: const Color(0xFFE5E5E5),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${totalPaid.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 24 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Total Paid',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollDetailRow(String label, String value, bool isSmallScreen, bool isTablet) {
    final labelSize = isTablet ? 15.0 : 14.0;
    final valueSize = isTablet ? 17.0 : 16.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollDetailColumn(String label, String value, bool isSmallScreen, bool isTablet) {
    final labelSize = isTablet ? 14.0 : 13.0;
    final valueSize = isTablet ? 17.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPayslipHistoryCard(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return _buildCard(
      icon: Icons.history,
      title: 'Payslip History',
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      children: [
        if (isLoadingPayslips)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 32 : 40),
              child: CircularProgressIndicator(
                color: const Color(0xFF9747FF),
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (payslipError != null)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 18),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: isTablet ? 24 : 22,
                    ),
                    SizedBox(width: isTablet ? 12 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error loading payslips',
                            style: GoogleFonts.inter(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 15,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            payslipError!,
                            style: GoogleFonts.inter(
                              color: Colors.red.shade600,
                              fontSize: isTablet ? 14 : 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadEmployeePayslips,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20,
                        vertical: isTablet ? 14 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 15 : 14,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (employeePayslips.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 32 : 40),
              child: Text(
                'No payslips found for this employee',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          )
        else
          ...employeePayslips.take(5).map((payslip) => _buildPayslipHistoryItem(payslip, isSmallScreen, isTablet)),

        if (employeePayslips.length > 5)
          Padding(
            padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
            child: Center(
              child: TextButton(
                onPressed: () => _viewAllPayslips(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20,
                    vertical: isTablet ? 12 : 10,
                  ),
                ),
                child: Text(
                  'View All ${employeePayslips.length} Payslips',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9747FF),
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 15,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPayslipHistoryItem(payslip_entity.Payslip payslip, bool isSmallScreen, bool isTablet) {
    final dateSize = isTablet ? 16.0 : 15.0;
    final detailSize = isTablet ? 14.0 : 13.0;
    final amountSize = isTablet ? 18.0 : 17.0;
    final buttonSize = isTablet ? 14.0 : 13.0;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                  style: GoogleFonts.inter(
                    fontSize: dateSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Pay Date: ${DateFormat('MMM dd, yyyy').format(payslip.payDate)}',
                  style: GoogleFonts.inter(
                    fontSize: detailSize,
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 8,
                    vertical: isTablet ? 5 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(payslip.statusEnum).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    payslip.statusEnum.displayName,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 12 : 11,
                      color: _getStatusColor(payslip.statusEnum),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${payslip.finalNetPay.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              TextButton(
                onPressed: () => _viewPayslip(payslip),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 14,
                    vertical: isTablet ? 8 : 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xFF9747FF).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9747FF),
                    fontSize: buttonSize,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(payslip_entity.PayslipStatus status) {
    switch (status) {
      case payslip_entity.PayslipStatus.draft:
        return Colors.orange[600]!;
      case payslip_entity.PayslipStatus.generated:
        return Colors.blue[600]!;
      case payslip_entity.PayslipStatus.sent:
        return const Color(0xFF9747FF);
      case payslip_entity.PayslipStatus.paid:
        return Colors.green[600]!;
      case payslip_entity.PayslipStatus.cancelled:
        return Colors.red[600]!;
      case payslip_entity.PayslipStatus.processing:
        return Colors.amber[600]!;
      case payslip_entity.PayslipStatus.failed:
        return Colors.red[600]!;
      case payslip_entity.PayslipStatus.pending:
        return Colors.grey[600]!;
    }
  }

  Widget _buildCard({
    IconData? icon,
    required String title,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
    required List<Widget> children,
  }) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 18.0;
    final titleSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;
    final iconSize = isTablet ? 22.0 : 20.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF9747FF),
                  size: iconSize,
                ),
                SizedBox(width: isTablet ? 12 : 10),
              ],
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen, bool isTablet, {bool isLast = false}) {
    final fontSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : (isSmallScreen ? 12 : 14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 130 : 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionRow(String label, String amount, bool isSmallScreen, bool isTablet) {
    final fontSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(bool isSmallScreen, bool isTablet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              title: Text(
                'Remove Employee',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
              content: Text(
                'Are you sure you want to remove ${widget.employee.displayName} from the team?',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 16 : 15,
                  color: const Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 18,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 15,
                      color: const Color(0xFF6B6B6B),
                      height: 1.2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          final navContext = context;

                          try {
                            final employeeViewModel = ref.read(employeeViewModelProvider.notifier);
                            await employeeViewModel.removeEmployeeFromTeam(widget.employee.email);

                            if (!mounted) return;
                            final navigator = Navigator.of(navContext);
                            navigator.pop();
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (!mounted) return;
                            navigator.pop();
                          } catch (e) {
                            if (!mounted) return;
                            final navigator = Navigator.of(navContext);
                            final messenger = ScaffoldMessenger.of(navContext);
                            
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to remove employee: $e',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Colors.red[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 18,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                  child: isDeleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                          ),
                        )
                      : Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 16 : 15,
                            height: 1.2,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editEmployee() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit employee functionality coming soon',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _viewPayslip(payslip_entity.Payslip payslip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayslipDetailsView(payslip: payslip),
      ),
    );
  }

  void _viewAllPayslips() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeePayslipListView(
          employee: widget.employee,
          payslips: employeePayslips,
          onRefresh: _loadEmployeePayslips,
        ),
      ),
    );
  }
}
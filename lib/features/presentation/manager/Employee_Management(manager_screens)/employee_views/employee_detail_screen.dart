import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/payslip.dart' as payslip_entity;
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../Payslip/Views/payslip_details_view.dart';
import 'employee_payslip_list_view.dart';
import '../../../widgets/employee/employee_detail_header.dart';
import '../../../widgets/employee/employee_detail_tab_navigation.dart';
import '../../../widgets/employee/employee_info_card.dart';
import '../../../widgets/employee/employee_info_row.dart';
import '../../../widgets/employee/payslip_summary_card.dart';
import '../../../widgets/employee/payslip_history_card.dart';

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
          EmployeeDetailHeader(
            employee: widget.employee,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            onBackPressed: () => Navigator.pop(context),
            onDeletePressed: () => _showDeleteDialog(isSmallScreen, isTablet),
            onEditPressed: _editEmployee,
          ),
          EmployeeDetailTabNavigation(
            currentTabIndex: _currentTabIndex,
            onTabChanged: (index) => _tabController.animateTo(index),
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
          ),
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

  Widget _buildDetailsTab(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final gap = isSmallScreen ? 16.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmployeeInfoCard(
            icon: Icons.person_outline,
            title: 'Personal Information',
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            children: [
              EmployeeInfoRow(
                label: 'Email',
                value: widget.employee.email,
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Username',
                value: widget.employee.username,
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Employee ID',
                value: widget.employee.userId,
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Role',
                value: widget.employee.role,
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Status',
                value: widget.employee.isActive ? 'Active' : 'Inactive',
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Joined Date',
                value: widget.employee.createdAt.toString().split(' ')[0],
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
                isLast: true,
              ),
            ],
          ),
          SizedBox(height: gap),
          EmployeeInfoCard(
            icon: Icons.work_outline,
            title: 'Employment Information',
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            children: [
              EmployeeInfoRow(
                label: 'Department',
                value: widget.employee.department ?? 'General',
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              ),
              EmployeeInfoRow(
                label: 'Position',
                value: widget.employee.position ?? 'Employee',
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
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
          PayslipSummaryCard(
            employeePayslips: employeePayslips,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
          SizedBox(height: gap),
          PayslipHistoryCard(
            employeePayslips: employeePayslips,
            isLoadingPayslips: isLoadingPayslips,
            payslipError: payslipError,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            onRefresh: _loadEmployeePayslips,
            onViewPayslip: _viewPayslip,
            onViewAll: _viewAllPayslips,
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
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            
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
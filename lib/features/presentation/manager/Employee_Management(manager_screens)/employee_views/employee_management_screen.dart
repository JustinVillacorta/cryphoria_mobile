import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/employee_management_skeleton.dart';
import '../employee_viewmodel/employee_state.dart';
import 'add_employee_screen.dart';
import 'employee_detail_screen.dart';
import '../../../widgets/employee/employee_management_app_bar.dart';
import '../../../widgets/employee/employee_search_field.dart';
import '../../../widgets/employee/employee_list_header.dart';
import '../../../widgets/employee/employee_filter_section.dart';
import '../../../widgets/employee/employee_card.dart';
import '../../../widgets/employee/employee_empty_state.dart';

class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends ConsumerState<EmployeeManagementScreen> {
  bool _isFilterExpanded = false;
  final List<String> _departments = ['Finance', 'Marketing', 'Operations', 'Sales', 'Technology'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(employeeViewModelProvider);
      if (state.filteredEmployees.isEmpty && !state.isLoading) {
        ref.read(employeeViewModelProvider.notifier).getManagerTeam().catchError((_) {
          ref.read(employeeViewModelProvider.notifier).loadSampleData();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final state = ref.watch(employeeViewModelProvider);

    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isDesktop ? 20.0 : isTablet ? 16.0 : 14.0;
    final appBarHeight = isDesktop ? 72.0 : isTablet ? 68.0 : 64.0;
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final sectionTitleSize = isDesktop ? 19.0 : isTablet ? 18.0 : 17.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final maxContentWidth = isDesktop ? 1200.0 : isTablet ? 900.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: EmployeeManagementAppBar(
        appBarHeight: appBarHeight,
        titleFontSize: titleFontSize,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
        isTablet: isTablet,
        onAddPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEmployeeScreen(),
            ),
          );
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: state.isLoading
              ? const EmployeeManagementSkeleton()
              : state.hasEmployees
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: EmployeeSearchField(
                            isTablet: isTablet,
                            onSearchChanged: (query) => ref
                                .read(employeeViewModelProvider.notifier)
                                .searchEmployees(query),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: EmployeeListHeader(
                            sectionTitleSize: sectionTitleSize,
                            isTablet: isTablet,
                            isFilterExpanded: _isFilterExpanded,
                            onFilterToggle: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isFilterExpanded ? (isSmallScreen ? 90 : 100) : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isFilterExpanded ? 1.0 : 0.0,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                isSmallScreen ? 12 : 16,
                                horizontalPadding,
                                isSmallScreen ? 8 : 12,
                              ),
                              child: EmployeeFilterSection(
                                departments: _departments,
                                selectedDepartment: state.selectedDepartment,
                                isSmallScreen: isSmallScreen,
                                isTablet: isTablet,
                                onDepartmentSelected: (department) => ref
                                    .read(employeeViewModelProvider.notifier)
                                    .filterByDepartment(department),
                                onClearFilter: () => ref
                                    .read(employeeViewModelProvider.notifier)
                                    .clearFilters(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              isSmallScreen ? 12 : 16,
                              horizontalPadding,
                              isSmallScreen ? 20 : 24,
                            ),
                            itemCount: state.filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = state.filteredEmployees[index];
                              return EmployeeCard(
                                employee: employee,
                                cardPadding: cardPadding,
                                isSmallScreen: isSmallScreen,
                                isTablet: isTablet,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmployeeDetailScreen(employee: employee),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : EmployeeEmptyState(
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),
        ),
      ),
    );
  }
}
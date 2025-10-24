import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/employee_management_skeleton.dart';
import '../employee_viewmodel/employee_viewmodel.dart';
import 'add_employee_screen.dart';
import 'employee_detail_screen.dart';

class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends ConsumerState<EmployeeManagementScreen> {
  late EmployeeViewModel _employeeViewModel;
  bool _isFilterExpanded = false;
  final List<String> _departments = ['Finance', 'Marketing', 'Operations', 'Sales', 'Technology'];

  @override
  void initState() {
    super.initState();
    _employeeViewModel = ref.read(employeeViewModelProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_employeeViewModel.employees.isEmpty && !_employeeViewModel.isLoading) {
        _employeeViewModel.getManagerTeam().catchError((_) {
          _employeeViewModel.loadSampleData();
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
    
    final viewModel = ref.watch(employeeViewModelProvider);
    
    // Responsive sizing
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isDesktop ? 20.0 : isTablet ? 16.0 : 14.0;
    final appBarHeight = isDesktop ? 72.0 : isTablet ? 68.0 : 64.0;
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final sectionTitleSize = isDesktop ? 19.0 : isTablet ? 18.0 : 17.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final maxContentWidth = isDesktop ? 1200.0 : isTablet ? 900.0 : double.infinity;

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
                vertical: verticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Employee Management',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9747FF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9747FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: isTablet ? 24 : 22,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEmployeeScreen(),
                          ),
                        );
                      },
                      tooltip: 'Add Employee',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: viewModel.isLoading
              ? const EmployeeManagementSkeleton()
              : viewModel.hasEmployees
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search employees...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF6B6B6B),
                                fontSize: isTablet ? 15 : 14,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: const Color(0xFF6B6B6B),
                                size: isTablet ? 22 : 20,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF9747FF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isTablet ? 16 : 14,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1A1A1A),
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: FontWeight.w400,
                            ),
                            onChanged: viewModel.searchEmployees,
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Section Header with Filter
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Employee List',
                                style: GoogleFonts.inter(
                                  fontSize: sectionTitleSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 14 : 12,
                                    vertical: isTablet ? 10 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9747FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.filter_list,
                                        color: const Color(0xFF9747FF),
                                        size: isTablet ? 18 : 16,
                                      ),
                                      SizedBox(width: isTablet ? 6 : 4),
                                      Text(
                                        'Filter',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF9747FF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: isTablet ? 15 : 14,
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 4 : 2),
                                      Icon(
                                        _isFilterExpanded ? Icons.expand_less : Icons.expand_more,
                                        color: const Color(0xFF9747FF),
                                        size: isTablet ? 18 : 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Filter Section
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isFilterExpanded ? (isSmallScreen ? 90 : 100) : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isFilterExpanded ? 1.0 : 0.0,
                            child: _buildFilterSection(
                              viewModel,
                              horizontalPadding,
                              isSmallScreen,
                              isTablet,
                            ),
                          ),
                        ),
                        
                        // Employee List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              isSmallScreen ? 12 : 16,
                              horizontalPadding,
                              isSmallScreen ? 20 : 24,
                            ),
                            itemCount: viewModel.employees.length,
                            itemBuilder: (context, index) {
                              final employee = viewModel.employees[index];
                              return _buildEmployeeCard(
                                employee,
                                cardPadding,
                                isSmallScreen,
                                isTablet,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : _buildEmptyState(isSmallScreen, isTablet, isDesktop),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final iconSize = isDesktop ? 140.0 : isTablet ? 130.0 : 120.0;
    final mainIconSize = isDesktop ? 72.0 : isTablet ? 68.0 : 64.0;
    final titleSize = isDesktop ? 22.0 : isTablet ? 21.0 : 20.0;
    final subtitleSize = isDesktop ? 16.0 : isTablet ? 15.5 : 15.0;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF9747FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: iconSize * 0.15,
                    right: iconSize * 0.15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9747FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: iconSize * 0.2,
                    left: iconSize * 0.2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9747FF).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    width: mainIconSize,
                    height: mainIconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9747FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: mainIconSize * 0.55,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            Text(
              'No employees yet',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Text(
              'Add your first employee to get started',
              style: GoogleFonts.inter(
                fontSize: subtitleSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    EmployeeViewModel viewModel,
    double horizontalPadding,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isSmallScreen ? 12 : 16,
        horizontalPadding,
        isSmallScreen ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Department',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _departments.map((department) {
                final isSelected = viewModel.selectedDepartment == department;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (isSelected) {
                        viewModel.clearFilters();
                      } else {
                        viewModel.filterByDepartment(department);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 18 : 16,
                        vertical: isTablet ? 10 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF9747FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF9747FF) 
                              : const Color(0xFFE5E5E5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        department,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: isTablet ? 14 : 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(
    employee,
    double cardPadding,
    bool isSmallScreen,
    bool isTablet,
  ) {
    final avatarRadius = isTablet ? 26.0 : 24.0;
    final nameFontSize = isTablet ? 17.0 : 16.0;
    final detailsFontSize = isTablet ? 14.0 : 13.0;
    
    // Check if profile image is valid
    final hasValidImage = employee.profileImage != null && 
                          employee.profileImage!.isNotEmpty &&
                          Uri.tryParse(employee.profileImage!)?.hasAbsolutePath == true;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailScreen(employee: employee),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9747FF).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color(0xFF9747FF).withOpacity(0.1),
                backgroundImage: hasValidImage
                    ? NetworkImage(employee.profileImage!)
                    : null,
                child: !hasValidImage
                    ? Icon(
                        Icons.person_outline,
                        color: const Color(0xFF9747FF),
                        size: avatarRadius * 0.9,
                      )
                    : null,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    employee.name,
                    style: GoogleFonts.inter(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 5 : 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.position ?? 'Employee',
                          style: GoogleFonts.inter(
                            fontSize: detailsFontSize,
                            color: const Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B6B6B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Text(
                        employee.employeeCode,
                        style: GoogleFonts.inter(
                          fontSize: detailsFontSize,
                          color: const Color(0xFF6B6B6B),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

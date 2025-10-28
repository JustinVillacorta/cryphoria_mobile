import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../../../widgets/employee/employee_form_header.dart';
import '../../../widgets/employee/employee_form_section_card.dart';
import '../../../widgets/employee/employee_form_input_field.dart';
import '../../../widgets/employee/employee_form_dropdown_field.dart';
import '../../../widgets/employee/employee_form_bottom_actions.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  String _selectedDepartment = 'IT Department';
  final List<String> _departments = [
    'IT Department',
    'Finance Department', 
    'Marketing Department',
    'Operations Department',
    'Sales Department',
    'HR Department'
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          EmployeeFormHeader(
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            onBackPressed: () => Navigator.pop(context),
            title: 'Add Employee',
            heading: 'Add New Employee',
            subtitle: 'Fill in the employee details below',
            icon: Icons.person_add_outlined,
          ),
          Expanded(
            child: _buildForm(isSmallScreen, isTablet, isDesktop),
          ),
          EmployeeFormBottomActions(
            isSubmitting: _isSubmitting,
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
            isDesktop: isDesktop,
            onCancel: () => Navigator.pop(context),
            onSubmit: _submitForm,
            submitButtonText: 'Add Employee',
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final maxWidth = isDesktop ? 700.0 : isTablet ? 600.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmployeeFormSectionCard(
                  icon: Icons.person_outline,
                  title: 'Employee Information',
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  children: [
                    SizedBox(height: isSmallScreen ? 14 : 16),
                    EmployeeFormInputField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter employee full name',
                      icon: Icons.person_outline,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      enabled: !_isSubmitting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    EmployeeFormInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter employee email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      enabled: !_isSubmitting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    EmployeeFormInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      enabled: !_isSubmitting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    EmployeeFormInputField(
                      controller: _positionController,
                      label: 'Job Position',
                      hint: 'Enter job position',
                      icon: Icons.work_outline,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      enabled: !_isSubmitting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Position is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    EmployeeFormDropdownField(
                      label: 'Department',
                      value: _selectedDepartment,
                      items: _departments,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDepartment = value;
                          });
                        }
                      },
                      icon: Icons.business_outlined,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final employeeViewModel = ref.read(employeeViewModelProvider.notifier);

      try {
        await employeeViewModel.addEmployeeToTeam(
          email: _emailController.text.trim(),
          position: _positionController.text.trim(),
          department: _selectedDepartment,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Employee added successfully!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isSubmitting = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error adding employee: $e',
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
      }
    }
  }
}
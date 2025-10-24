import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers - only the required fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  // Department dropdown
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
          // Custom Header with gradient
          _buildHeader(isSmallScreen, isTablet, isDesktop),
          // Combined Form Content
          Expanded(
            child: _buildCombinedForm(isSmallScreen, isTablet, isDesktop),
          ),
          // Bottom Action Buttons
          _buildBottomActions(isSmallScreen, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final titleSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final headingSize = isDesktop ? 26.0 : isTablet ? 24.0 : 22.0;
    final subtitleSize = isDesktop ? 17.0 : isTablet ? 16.0 : 15.0;
    final iconSize = isDesktop ? 68.0 : isTablet ? 64.0 : 60.0;
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9747FF), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 24 : isTablet ? 20 : 16,
            isSmallScreen ? 4 : 8,
            isDesktop ? 24 : isTablet ? 20 : 16,
            isSmallScreen ? 16 : 20,
          ),
          child: Column(
            children: [
              // Top Navigation
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
                  ),
                  Text(
                    'Add Employee',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(width: isTablet ? 52 : 48), // Balance the back button
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              // Add Employee Icon and Description
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 18 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person_add_outlined,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  Text(
                    'Add New Employee',
                    style: GoogleFonts.inter(
                      fontSize: headingSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    'Fill in the employee details below',
                    style: GoogleFonts.inter(
                      fontSize: subtitleSize,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedForm(bool isSmallScreen, bool isTablet, bool isDesktop) {
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
                _buildSectionCard(
                  icon: Icons.person_outline,
                  title: 'Employee Information',
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  children: [
                    SizedBox(height: isSmallScreen ? 14 : 16),
                    _buildInputField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter employee full name',
                      icon: Icons.person_outline,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter employee email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
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
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildInputField(
                      controller: _positionController,
                      label: 'Job Position',
                      hint: 'Enter job position',
                      icon: Icons.work_outline,
                      isSmallScreen: isSmallScreen,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Position is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildDropdownField(isSmallScreen, isTablet),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
    required List<Widget> children,
  }) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 18.0;
    final titleSize = isDesktop ? 19.0 : isTablet ? 18.0 : 17.0;
    final iconSize = isTablet ? 24.0 : 22.0;
    
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9747FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF9747FF),
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isTablet ? 14 : 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isSmallScreen,
    required bool isTablet,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final labelSize = isTablet ? 16.0 : 15.0;
    final hintSize = isTablet ? 15.0 : 14.0;
    final iconSize = isTablet ? 22.0 : 20.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          enabled: !_isSubmitting,
          style: GoogleFonts.inter(
            fontSize: hintSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF6B6B6B),
              fontSize: hintSize,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF9747FF), size: iconSize),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9747FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 16,
              vertical: isTablet ? 16 : 14,
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(bool isSmallScreen, bool isTablet) {
    final labelSize = isTablet ? 16.0 : 15.0;
    final dropdownSize = isTablet ? 15.0 : 14.0;
    final iconSize = isTablet ? 22.0 : 20.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: GoogleFonts.inter(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          items: _departments.map((department) {
            return DropdownMenuItem(
              value: department,
              child: Text(
                department,
                style: GoogleFonts.inter(
                  fontSize: dropdownSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
          onChanged: _isSubmitting ? null : (value) {
            if (value != null) {
              setState(() {
                _selectedDepartment = value;
              });
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.business_outlined,
              color: const Color(0xFF9747FF),
              size: iconSize,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9747FF), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 16,
              vertical: isTablet ? 16 : 14,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF6B6B6B),
            size: isTablet ? 26 : 24,
          ),
          style: GoogleFonts.inter(
            fontSize: dropdownSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final buttonPadding = isTablet ? 16.0 : 14.0;
    final fontSize = isTablet ? 17.0 : 16.0;
    final horizontalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isSmallScreen ? 14 : 16,
        horizontalPadding,
        isSmallScreen ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  side: BorderSide(
                    color: _isSubmitting 
                        ? const Color(0xFFE5E5E5) 
                        : const Color(0xFF9747FF),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: _isSubmitting 
                        ? const Color(0xFF6B6B6B) 
                        : const Color(0xFF9747FF),
                  ),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 14),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  disabledBackgroundColor: const Color(0xFF9747FF).withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF9747FF).withOpacity(0.3),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      )
                    : Text(
                        'Add Employee',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
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

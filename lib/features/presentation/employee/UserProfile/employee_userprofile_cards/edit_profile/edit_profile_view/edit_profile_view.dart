import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/presentation/employee/UserProfile/employee_userprofile_cards/edit_profile/edit_profile_viewmodel/edit_profile_viewmodel.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final AuthUser currentUser;

  const EditProfileScreen({
    super.key,
    required this.currentUser,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _securityQuestionController = TextEditingController();
  final TextEditingController _securityAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController.text = widget.currentUser.firstName;
    _lastNameController.text = widget.currentUser.lastName ?? '';
    _phoneController.text = widget.currentUser.phoneNumber ?? '';
    _companyController.text = widget.currentUser.company ?? '';
    _departmentController.text = widget.currentUser.department ?? '';
    _securityQuestionController.text = widget.currentUser.securityQuestion ?? '';
    _securityAnswerController.text = widget.currentUser.securityAnswer ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(editProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('First Name', _firstNameController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Last Name', _lastNameController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Phone Number', _phoneController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Company', _companyController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Department', _departmentController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Security Question', _securityQuestionController, isRequired: true),
                      const SizedBox(height: 25),
                      _buildTextField('Security Answer', _securityAnswerController, isRequired: true, isObscure: true),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: editProfileState.isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: editProfileState.isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: editProfileState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false, bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.purple),
            ),
            fillColor: Colors.grey[50],
            filled: true,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  void _saveChanges() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      try {
        final updatedUser = await ref.read(editProfileProvider.notifier).updateProfileAndReturn(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          company: _companyController.text.trim(),
          department: _departmentController.text.trim(),
          securityQuestion: _securityQuestionController.text.trim(),
          securityAnswer: _securityAnswerController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedUser);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Failed to update profile';
          if (e is ServerException) {
            errorMessage = e.message;
          } else if (e.toString().contains('Network')) {
            errorMessage = 'Network error. Please check your connection.';
          } else {
            errorMessage = 'An unexpected error occurred';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _departmentController.dispose();
    _securityQuestionController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }
}
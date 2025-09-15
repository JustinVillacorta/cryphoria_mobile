import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/Register/ViewModel/register_view_model.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/ApprovalPending/approval_pending_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_dart.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegisterViewModel _viewModel = sl<RegisterViewModel>();
  
  // Role selection state
  String _selectedRole = 'Employee'; // Default to Employee

  @override
  void dispose() {
    _viewModel.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Register and simplify crypto bookkeeping and invoicing.',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 30),
                
                const SizedBox(height: 16),
                buildInputField('Username', controller: _usernameController),
                const SizedBox(height: 16),
                buildInputField('Email', controller: _emailController),
                const SizedBox(height: 16),
                // Role Selection Dropdown
                buildRoleSelector(),
                const SizedBox(height: 24),
                buildInputField(
                  'Password',
                  controller: _passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 24),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await _viewModel.register(
                        _usernameController.text,
                        _passwordController.text,
                        _emailController.text,
                        _selectedRole,
                      );
                      if (!mounted) return;
                      
                      if (_viewModel.authUser != null) {
                        // Check if approval is pending (shouldn't happen for registration, but just in case)
                        if (_viewModel.isApprovalPending) {
                          // Navigate to approval pending screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApprovalPendingView(
                                authUser: _viewModel.authUser!,
                                onRetry: () => {},
                                onLogout: () async {
                                  try {
                                    // Clear authentication data first to prevent issues
                                    final authDataSource = sl<AuthLocalDataSource>();
                                    await authDataSource.clearAuthData();
                                    print('Register logout: Local authentication data cleared successfully');
                                  } catch (e) {
                                    print('Register logout: Error clearing authentication data: $e');
                                  }
                                  
                                  // Navigate to login screen
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LogIn()),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        } else {
                          // Role-based navigation after successful registration
                          if (_viewModel.authUser!.role == 'Manager') {
                            // Reset page notifiers to default before navigation
                            selectedPageNotifer.value = 0;
                            selectedEmployeePageNotifer.value = 0;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const WidgetTree()),
                            );
                          } else {
                            // Reset page notifiers to default before navigation
                            selectedPageNotifer.value = 0;
                            selectedEmployeePageNotifer.value = 0;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const EmployeeWidgetTree()),
                            );
                          }
                        }
                      } else if (_viewModel.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_viewModel.error!),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider with OR
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors
                              .white60, // 👈 change this to any color you want
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white60)),
                  ],
                ),
                const SizedBox(height: 20),
                

                const SizedBox(height: 30),
                // Log In redirect
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an Account? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Role selector dropdown
  Widget buildRoleSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: const Text(
            'Select Role',
            style: TextStyle(color: Colors.grey),
          ),
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(
              value: 'Manager',
              child: Text(
                'Manager',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DropdownMenuItem(
              value: 'Employee',
              child: Text(
                'Employee',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedRole = newValue;
              });
            }
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Reusable text input
  Widget buildInputField(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Reusable social button
  Widget buildSocialButton({
    IconData? icon,
    String? iconUrl,
    required String text,
    required Color color,
    MainAxisAlignment alignment = MainAxisAlignment.start,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment,
          children: [
            if (iconUrl != null)
              Image.network(
                iconUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 24),
              )
            else
              Icon(icon ?? Icons.error, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

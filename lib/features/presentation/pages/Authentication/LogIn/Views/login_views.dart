import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/Register/Views/register_view.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/ApprovalPending/approval_pending_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_dart.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel _viewModel = sl<LoginViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() async {
    if (_viewModel.authUser != null) {
      // Check if approval is pending
      if (_viewModel.isApprovalPending) {
        // Navigate to approval pending screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ApprovalPendingView(
              authUser: _viewModel.authUser!,
              onRetry: () => _checkApprovalStatus(),
              onLogout: () => _logout(),
            ),
          ),
        );
      } else {
        // Role-based navigation after successful login
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
  }

  void _checkApprovalStatus() async {
    // This will be handled by the ApprovalPendingView's polling mechanism
    // Just refresh the current state
    if (_viewModel.authUser != null && !_viewModel.isApprovalPending) {
      // Role-based navigation after approval
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
  }

  void _logout() async {
    try {
      // Clear authentication data first to prevent issues
      final authDataSource = sl<AuthLocalDataSource>();
      await authDataSource.clearAuthData();
      print('Login logout: Local authentication data cleared successfully');
    } catch (e) {
      print('Login logout: Error clearing authentication data: $e');
    }
    
    // Navigate to login screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LogIn()),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _usernameController.dispose();
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
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Log in to manage your crypto finances smarter and faster.',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 30),
                // Input Fields
                buildInputField(
                  'Username or email',
                  controller: _usernameController,
                ),
                const SizedBox(height: 16),
                buildInputField(
                  'Password',
                  controller: _passwordController,
                  obscure: true,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Add navigation or dialog here
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Log In Button
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
                    onPressed: () {
                      _viewModel.login(
                        _usernameController.text,
                        _passwordController.text,
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register redirect
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const RegisterView(),
                        )),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Don\'t have an Account? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Register',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  //hihiwalay to sa widget
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
}

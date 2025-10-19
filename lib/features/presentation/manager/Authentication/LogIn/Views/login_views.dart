import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Forgot_Password/Views/forgot_password_request_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_tree.dart';
import 'package:cryphoria_mobile/shared/validation/validators.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState<LogIn> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _submitted = false;
  String _email = '';
  bool _isPasswordVisible = false; // 👈 Added for show/hide password toggle

  LoginViewModel get _viewModel => ref.read(loginViewModelProvider);

  void _onViewModelChanged(LoginViewModel viewModel) async {
    if (viewModel.authUser != null) {
      ref.read(userProvider.notifier).state = viewModel.authUser;

      if (viewModel.authUser!.role == 'Manager') {
        ref.read(selectedPageProvider.notifier).state = 0;
        ref.read(selectedEmployeePageProvider.notifier).state = 0;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WidgetTree()),
          (route) => false,
        );
      } else {
        ref.read(selectedPageProvider.notifier).state = 0;
        ref.read(selectedEmployeePageProvider.notifier).state = 0;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeWidgetTree()),
          (route) => false,
        );
      }
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.error!)));
    }
  }

  void _login() {
    setState(() => _submitted = true);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill the highlighted fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginViewModel>(
      loginViewModelProvider,
      (previous, next) => _onViewModelChanged(next),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildLoginForm(context),
                  ),
                ],
              );
            } else {
              return _buildLoginForm(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final viewModel = ref.watch(loginViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 800;
    final double horizontalPadding = isWide ? 48.0 : 32.0;
    final double formMaxWidth =
        screenWidth > 1200 ? 520.0 : (isWide ? 460.0 : 400.0);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(horizontalPadding),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to manage your crypto finances smarter and faster.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.validateEmail,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                    onChanged: (v) => setState(() => _email = (v ?? '').trim()),
                    suffixIcon: (_submitted && _email.isNotEmpty)
                        ? (AppValidators.validateEmail(_email) == null
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.error_outline,
                                color: Colors.red))
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Password field with show/hide icon 👇
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: !_isPasswordVisible, // 👈 toggled visibility
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Password is required';
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordRequestView(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Doesn't have an account? ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterView()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (viewModel.error != null && viewModel.error!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        viewModel.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    void Function(String?)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.black54,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        errorMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
    );
  }
}

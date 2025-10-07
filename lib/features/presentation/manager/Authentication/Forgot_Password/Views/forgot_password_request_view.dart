import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Forgot_Password/Views/forgot_password_confirm_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';

class ForgotPasswordRequestView extends ConsumerStatefulWidget {
  const ForgotPasswordRequestView({super.key});

  @override
  ConsumerState<ForgotPasswordRequestView> createState() => _ForgotPasswordRequestViewState();
}

class _ForgotPasswordRequestViewState extends ConsumerState<ForgotPasswordRequestView> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(32),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                      'Don\'t worry! Enter your email address and we\'ll send you a code to reset your password.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Input Field
                    _buildEmailField(),
                    const SizedBox(height: 24),

                    // Send Code Button
                    _buildSendCodeButton(),
                    const SizedBox(height: 24),

                    // Back to Login
                    _buildBackToLogin(),

                    // Error message
                    _buildErrorMessage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Colors.black54,
          size: 20,
        ),
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
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
    );
  }

  Widget _buildSendCodeButton() {
    final viewModel = ref.watch(forgotPasswordRequestViewModelProvider);
    
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : _sendResetCode,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Send Reset Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Remember your password? ',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LogIn()),
            );
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    final viewModel = ref.watch(forgotPasswordRequestViewModelProvider);
    
    if (viewModel.error != null && viewModel.error!.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
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
      );
    }
    return const SizedBox.shrink();
  }

  void _sendResetCode() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Basic email validation
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = ref.read(forgotPasswordRequestViewModelProvider);

    await viewModel.requestPasswordReset(_emailController.text);
    
    if (!mounted) return;
    
    if (viewModel.error == null && viewModel.isRequestSent) {
      // Password reset request successful - navigate to confirmation screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset code sent successfully! Check your email.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordConfirmView(
            email: _emailController.text,
          ),
        ),
      );
    }
  }
}

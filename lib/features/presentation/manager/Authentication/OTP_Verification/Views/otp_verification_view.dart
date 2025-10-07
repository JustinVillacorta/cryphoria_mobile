import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';

class OTPVerificationView extends ConsumerStatefulWidget {
  final String email;
  
  const OTPVerificationView({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OTPVerificationView> createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends ConsumerState<OTPVerificationView> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
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
                    // Title
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'We\'ve sent a verification code to\n${widget.email}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Field
                    _buildOTPField(),
                    const SizedBox(height: 24),

                    // Verify Button
                    _buildVerifyButton(),
                    const SizedBox(height: 24),

                    // Resend Code
                    _buildResendCode(),
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

  Widget _buildOTPField() {
    return TextField(
      controller: _otpController,
      focusNode: _otpFocusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        labelText: 'Enter OTP Code',
        hintText: '000000',
        counterText: '', // Hide character counter
        prefixIcon: const Icon(
          Icons.security_outlined,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
    );
  }

  Widget _buildVerifyButton() {
    final viewModel = ref.watch(otpVerificationViewModelProvider);
    
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : _verifyOTP,
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
              'Verify Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildResendCode() {
    final viewModel = ref.watch(otpVerificationViewModelProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Didn\'t receive the code? ',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: viewModel.isLoading ? null : _resendCode,
          child: Text(
            'Resend Code',
            style: TextStyle(
              color: viewModel.isLoading ? Colors.grey : const Color(0xFF8B5CF6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Wrong email? ',
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
    final viewModel = ref.watch(otpVerificationViewModelProvider);
    
    if (viewModel.error != null && viewModel.error!.isNotEmpty) {
      return Container(
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

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = ref.read(otpVerificationViewModelProvider);

    await viewModel.verifyOTP(
      widget.email,
      _otpController.text,
    );
    
    if (!mounted) return;
    
    if (viewModel.error == null && viewModel.isVerified) {
      // OTP verification successful - redirect to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()),
      );
    }
  }

  void _resendCode() async {
    final viewModel = ref.read(otpVerificationViewModelProvider);
    
    await viewModel.resendOTP(widget.email);
    
    if (!mounted) return;
    
    if (viewModel.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

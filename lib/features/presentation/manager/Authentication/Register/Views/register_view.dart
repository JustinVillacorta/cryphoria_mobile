import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';

import 'package:cryphoria_mobile/features/presentation/widgets/auth/terms_and_conditions_content.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/auth/role_selector.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/OTP_Verification/Views/otp_verification_view.dart';
import 'package:cryphoria_mobile/shared/validation/validators.dart';
import 'package:cryphoria_mobile/shared/widgets/password_strength_bar.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _securityAnswerController = TextEditingController();
  String _password = '';
  
  // Role selection state
  String _selectedRole = 'Employee'; // Default to Employee

  // Gesture recognizers for tappable Terms/Privacy text
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  // Whether the user has accepted terms (main checkbox)
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final accepted = await _showTermsModal();
        if (accepted == true && mounted) setState(() => _agreed = true);
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final accepted = await _showPrivacyModal();
        if (accepted == true && mounted) setState(() => _agreed = true);
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<bool?> _showTermsModal() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _AgreementDialog(title: 'Terms and Conditions'),
    );
  }

  Future<bool?> _showPrivacyModal() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _AgreementDialog(title: 'Privacy Policy'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For tablets/desktop, show side-by-side layout
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  // Left side - Sign Up
                  Expanded(
                    child: _buildRegisterForm(context),
                  ),
                  // Right side - Log In (hidden for now, show register)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // For mobile, show full screen register
              return _buildRegisterForm(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final viewModel = ref.watch(registerViewModelProvider);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Title
                const Text(
                  'Create Account',
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
                  'Sign up and simplify crypto bookkeeping and invoicing.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'I am creating an account as a:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Role Selection
                RoleSelector(
                  selectedRole: _selectedRole,
                  onRoleSelected: (role) => setState(() => _selectedRole = role),
                ),
                const SizedBox(height: 12),

                // First Name field
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (v) => AppValidators.validateName(v, min: 2, max: 50),
                  inputFormatters: AppValidators.nameInputFormatters,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Last Name field
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (v) => AppValidators.validateName(v, min: 2, max: 50),
                  inputFormatters: AppValidators.nameInputFormatters,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Username field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.account_circle_outlined,
                  validator: (v) => AppValidators.validateUsername(v, min: 3, max: 20),
                  inputFormatters: AppValidators.usernameInputFormatters,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => AppValidators.validatePassword(v, min: AppValidators.defaultPasswordMin, max: AppValidators.defaultPasswordMax),
                  onChanged: (v) => setState(() => _password = v ?? ''),
                ),
                PasswordStrengthBar(password: _password),
                const SizedBox(height: 20),

                // Confirm Password field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => AppValidators.validateConfirmPassword(v, _passwordController.text),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Security Answer field
                _buildTextField(
                  controller: _securityAnswerController,
                  label: 'Security Answer (e.g., My favorite pet is Max)',
                  icon: Icons.security_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Security answer is required' : null,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: _agreed,
                        onChanged: (value) async {
                          // Open modal when user taps checkbox
                          final accepted = await _showTermsModal();
                          if (accepted == true && mounted) setState(() => _agreed = true);
                        },
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                            text: TextSpan(
                              text: 'I agree to the ',
                              style: const TextStyle(color: Colors.black54, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _termsRecognizer,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _privacyRecognizer,
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _register,
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
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Log In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an Account? ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Error message
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
    ));
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    void Function(String?)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
    );
  }

  void _register() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the highlighted fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = ref.read(registerViewModelProvider);

    await viewModel.register(
      _usernameController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      _emailController.text.trim(),
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _securityAnswerController.text.trim(),
      _selectedRole,
    );

    if (!mounted) return;

    if (viewModel.error == null && viewModel.registerResponse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please verify your email.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationView(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _AgreementDialog extends StatefulWidget {
  final String title;
  const _AgreementDialog({Key? key, required this.title}) : super(key: key);

  @override
  State<_AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<_AgreementDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_checked && _scrollController.position.atEdge) {
      final isBottom = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
      if (isBottom) {
        setState(() => _checked = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const TermsAndConditionsContent(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _checked,
                  onChanged: (v) => setState(() => _checked = v ?? false),
                  activeColor: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('I agree to the Terms and Conditions and Privacy Policy.'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: _checked ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

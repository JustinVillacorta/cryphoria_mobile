import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  String _selectedRole = 'Employee';
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final isTablet = size.width > 600;
            final isLargeTablet = size.width > 900;
            final isDesktop = size.width > 1200;
            
            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: const Color(0xFF9747FF),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 120,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Cryphoria',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                'Smarter Crypto Finance for Growth',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _buildRegisterForm(context, size, isTablet, isLargeTablet, isDesktop),
                  ),
                ],
              );
            } else {
              return _buildRegisterForm(context, size, isTablet, isLargeTablet, isDesktop);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, Size size, bool isTablet, bool isLargeTablet, bool isDesktop) {
    final viewModel = ref.watch(registerViewModelProvider);
    final isSmallScreen = size.height < 700;
    
    final horizontalPadding = isDesktop ? 60.0 : isLargeTablet ? 48.0 : isTablet ? 36.0 : 24.0;
    final formMaxWidth = isDesktop ? 480.0 : isLargeTablet ? 520.0 : isTablet ? 560.0 : 400.0;
    final titleFontSize = isDesktop ? 36.0 : isLargeTablet ? 34.0 : isTablet ? 32.0 : isSmallScreen ? 28.0 : 32.0;
    final subtitleFontSize = isDesktop ? 16.0 : isLargeTablet ? 15.5 : isTablet ? 15.0 : 14.0;
    final fieldSpacing = isSmallScreen ? 14.0 : isTablet ? 18.0 : 16.0;
    final buttonHeight = isTablet ? 56.0 : isSmallScreen ? 50.0 : 52.0;
    final verticalPadding = isSmallScreen ? 20.0 : isTablet ? 40.0 : 32.0;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
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
                  Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  
                  Text(
                    'Sign up and simplify crypto bookkeeping and invoicing.',
                    style: GoogleFonts.inter(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B6B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 24 : isTablet ? 32 : 28),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'I am creating an account as a:',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  RoleSelector(
                    selectedRole: _selectedRole,
                    onRoleSelected: (role) => setState(() => _selectedRole = role),
                  ),
                  SizedBox(height: fieldSpacing + 4),

                  _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                    validator: (v) => AppValidators.validateName(v, min: 2, max: 50),
                    inputFormatters: AppValidators.nameInputFormatters,
                    onChanged: (_) {},
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    validator: (v) => AppValidators.validateName(v, min: 2, max: 50),
                    inputFormatters: AppValidators.nameInputFormatters,
                    onChanged: (_) {},
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.account_circle_outlined,
                    validator: (v) => AppValidators.validateUsername(v, min: 3, max: 20),
                    inputFormatters: AppValidators.usernameInputFormatters,
                    onChanged: (_) {},
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: AppValidators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    onChanged: (_) {},
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    validator: (v) => AppValidators.validatePassword(v, min: AppValidators.defaultPasswordMin, max: AppValidators.defaultPasswordMax),
                    onChanged: (v) => setState(() => _password = v ?? ''),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B6B6B),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  PasswordStrengthBar(password: _password),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    validator: (v) => AppValidators.validateConfirmPassword(v, _passwordController.text),
                    onChanged: (_) {},
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B6B6B),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  _buildTextField(
                    controller: _securityAnswerController,
                    label: 'Security Answer (e.g., My favorite pet is Max)',
                    icon: Icons.security_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Security answer is required' : null,
                    onChanged: (_) {},
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (value) async {
                            final accepted = await _showTermsModal();
                            if (accepted == true && mounted) setState(() => _agreed = true);
                          },
                          activeColor: const Color(0xFF9747FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6B6B6B),
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9747FF),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9747FF),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
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
                  SizedBox(height: isSmallScreen ? 24 : isTablet ? 32 : 28),

                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9747FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF9747FF).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                          : Text(
                              'Sign Up',
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 17 : 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an Account? ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B6B6B),
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9747FF),
                              fontSize: isSmallScreen ? 14 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (viewModel.error != null && viewModel.error!.isNotEmpty) ...[
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: GoogleFonts.inter(
                                color: Colors.red.shade700,
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    final fontSize = isSmallScreen ? 14.0 : 15.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final verticalPadding = isSmallScreen ? 14.0 : isTablet ? 18.0 : 16.0;
    
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.inter(
        color: const Color(0xFF1A1A1A),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6B6B6B),
          size: iconSize,
        ),
        suffixIcon: suffixIcon,
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF6B6B6B),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9747FF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: isSmallScreen ? 12 : 13,
          fontWeight: FontWeight.w400,
        ),
        errorMaxLines: 2,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: verticalPadding,
        ),
      ),
    );
  }

  void _register() async {
    setState(() => _submitted = true);
    
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Terms and Privacy Policy',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fix the highlighted fields',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
        SnackBar(
          content: Text(
            'Registration successful! Please verify your email.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
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
                  activeColor: const Color(0xFF9747FF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions and Privacy Policy.',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Close',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: _checked ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            'Accept',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

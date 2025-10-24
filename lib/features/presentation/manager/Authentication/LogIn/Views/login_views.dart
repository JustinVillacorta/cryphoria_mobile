import 'package:cryphoria_mobile/features/presentation/widgets/navigation/employee_widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Forgot_Password/Views/forgot_password_request_view.dart';
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
  String? _noAccountEmail;
  bool _obscurePassword = true;

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
      final err = viewModel.error!;
      if (_isNoAccountError(err)) {
        final email = _emailController.text.trim();
        if (!mounted) return;
        setState(() {
          _noAccountEmail = email.isNotEmpty ? email : null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              err,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }
  }

  bool _isNoAccountError(String error) {
    final s = error.toLowerCase();
    return s.contains('user not found') ||
        s.contains('no user') ||
        s.contains('no account') ||
        s.contains('account not found') ||
        s.contains('not registered') ||
        s.contains('email not found') ||
        s.contains("doesn't exist") ||
        s.contains('does not exist') ||
        s.contains('unregistered') ||
        s.contains('unknown user') ||
        s.contains('email not registered') ||
        s.contains('record not found');
  }

  void _login() {
    setState(() => _submitted = true);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill out the highlighted fields',
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final isTablet = size.width > 600;
            final isLargeTablet = size.width > 900;
            final isDesktop = size.width > 1200;
            
            if (isDesktop) {
              // Desktop: Two-column layout
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
                    child: _buildLoginForm(context, size, isTablet, isLargeTablet, isDesktop),
                  ),
                ],
              );
            } else {
              // Mobile & Tablet: Single column
              return _buildLoginForm(context, size, isTablet, isLargeTablet, isDesktop);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, Size size, bool isTablet, bool isLargeTablet, bool isDesktop) {
    final viewModel = ref.watch(loginViewModelProvider);
    final isSmallScreen = size.height < 700;
    
    // Responsive sizing
    final horizontalPadding = isDesktop ? 60.0 : isLargeTablet ? 48.0 : isTablet ? 36.0 : 24.0;
    final formMaxWidth = isDesktop ? 480.0 : isLargeTablet ? 520.0 : isTablet ? 560.0 : 400.0;
    final titleFontSize = isDesktop ? 36.0 : isLargeTablet ? 34.0 : isTablet ? 32.0 : isSmallScreen ? 28.0 : 32.0;
    final subtitleFontSize = isDesktop ? 16.0 : isLargeTablet ? 15.5 : isTablet ? 15.0 : 14.0;
    final fieldSpacing = isSmallScreen ? 16.0 : isTablet ? 22.0 : 20.0;
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
                  // Error banners
                  if (viewModel.error != null && 
                      viewModel.error!.isNotEmpty && 
                      _isNoAccountError(viewModel.error!)) ...[
                    _buildInfoBanner(
                      message: 'No account exists for \'${_emailController.text.trim()}\'.',
                      onCreateAccount: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterView()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],
                  
                  if (_noAccountEmail != null && _noAccountEmail!.trim().isNotEmpty) ...[
                    _buildInfoBanner(
                      message: 'No account exists for $_noAccountEmail.',
                      onCreateAccount: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterView()),
                        );
                      },
                      onDismiss: () {
                        setState(() => _noAccountEmail = null);
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],
                  
                  // Title
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  
                  // Subtitle
                  Text(
                    'Log in to manage your crypto finances smarter and faster.',
                    style: GoogleFonts.inter(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B6B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 32 : isTablet ? 48 : 40),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.validateEmail,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    onChanged: (v) => setState(() => _email = (v ?? '').trim()),
                    suffixIcon: (_submitted && _email.isNotEmpty)
                        ? (AppValidators.validateEmail(_email) == null
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                            : const Icon(Icons.error_outline, color: Colors.red, size: 20))
                        : null,
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: fieldSpacing),

                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Password is required';
                      return null;
                    },
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
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordRequestView(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9747FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Login Button
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _login,
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
                              'Log In',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B6B6B),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterView()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9747FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Error message
                  if (viewModel.error != null && 
                      viewModel.error!.isNotEmpty &&
                      !_isNoAccountError(viewModel.error!)) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                                fontSize: 14,
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

  Widget _buildInfoBanner({
    required String message,
    required VoidCallback onCreateAccount,
    VoidCallback? onDismiss,
    bool isSmallScreen = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.orange.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: onCreateAccount,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (onDismiss != null)
                      TextButton(
                        onPressed: onDismiss,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Dismiss',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
    bool isSmallScreen = false,
    bool isTablet = false,
  }) {
    final double fontSize = isSmallScreen ? 14 : isTablet ? 15 : 16;
    final double paddingVertical = isSmallScreen ? 12 : isTablet ? 14 : 16;
    
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
          size: 20,
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
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        errorMaxLines: 2,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingVertical),
      ),
    );
  }
}
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Forgot_Password/Views/forgot_password_request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';

class ChangePasswordView extends ConsumerStatefulWidget {
  const ChangePasswordView({super.key});

  @override
  ConsumerState<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends ConsumerState<ChangePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    // Listen to VM state to drive UI dialogs
    ref.listen<AsyncValue<void>>(managerChangePasswordVmProvider,
        (previous, next) async {
      next.when(
        data: (_) async {
          _hideLoading();
          await _showMessageDialog(
            title: 'Success',
            message: 'Password updated successfully.',
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        },
        loading: () {
          _showLoading();
        },
        error: (err, _) async {
          _hideLoading();
          await _showMessageDialog(
            title: 'Error',
            message: err.toString(),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF1A1D1F),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: false,
        title: Text(
          'Change Password',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your new password must be at least 8 characters, including a number and a symbol.',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6F7787),
              ),
            ),
          
            const SizedBox(height: 20),
            _PasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
            ),
            const SizedBox(height: 20),
            _PasswordField(
              controller: _newPasswordController,
              label: 'New Password',
            ),
            const SizedBox(height: 20),
            _PasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE6E8EB)),
                      foregroundColor: const Color(0xFF1A1D1F),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onUpdatePasswordPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff9747FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.helper,
  });

  final TextEditingController controller;
  final String label;
  final Widget? helper;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE6E8EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE6E8EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6F4CF5), width: 1.2),
            ),
            suffixIcon: widget.helper == null
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A94A6),
                    ),
                  )
                : IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A94A6),
                    ),
                  ),
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 8),
          widget.helper!,
        ],
      ],
    );
  }
}

extension on _ChangePasswordViewState {
  Future<void> _onUpdatePasswordPressed() async {
    final current = _currentPasswordController.text.trim();
    final newPw = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // Basic validation
    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      await _showMessageDialog(
        title: 'Missing Information',
        message: 'Please fill in all fields.',
      );
      return;
    }
    if (newPw != confirm) {
      await _showMessageDialog(
        title: 'Passwords Do Not Match',
        message: 'Please make sure both new passwords match.',
      );
      return;
    }
    if (newPw.length < 8) {
      await _showMessageDialog(
        title: 'Weak Password',
        message: 'New password must be at least 8 characters.',
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Confirm Change',
      message: 'Are you sure you want to update your password?',
      confirmText: 'Update',
    );
    if (confirmed != true) return;

    // Trigger VM call; UI reacts via ref.listen above
    await ref.read(managerChangePasswordVmProvider.notifier).changePassword(
          currentPassword: current,
          newPassword: newPw,
          confirmPassword: confirm,
        );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'OK',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessageDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _showLoading() {
    if (_loadingShown) return;
    _loadingShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _hideLoading() {
    if (!_loadingShown) return;
    _loadingShown = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}

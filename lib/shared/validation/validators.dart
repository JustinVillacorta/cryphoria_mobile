import 'package:flutter/services.dart';

class AppValidators {
  static const int defaultNameMin = 2;
  static const int defaultNameMax = 50;
  static const int defaultUsernameMin = 3;
  static const int defaultUsernameMax = 20;
  static const int defaultPasswordMin = 8;
  static const int defaultPasswordMax = 64;

  static final RegExp _nameRegex = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]+");
  static final RegExp _usernameRegex = RegExp(r"^[a-zA-Z0-9](?:[a-zA-Z0-9._-]{1,}[a-zA-Z0-9])?$" );
  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,63}$",
    caseSensitive: false,
  );
  static final RegExp _hasLower = RegExp(r"[a-z]");
  static final RegExp _hasUpper = RegExp(r"[A-Z]");
  static final RegExp _hasDigit = RegExp(r"\d");
  static final RegExp _hasSymbol = RegExp(r"[^A-Za-z0-9]");

  static final List<TextInputFormatter> nameInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ' -]")),
  ];

  static final List<TextInputFormatter> usernameInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9._-]")),
  ];

  static String? validateName(String? value, {int min = defaultNameMin, int max = defaultNameMax}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Name is required';
    if (v.length < min) return 'Name must be at least $min characters';
    if (v.length > max) return 'Name must be at most $max characters';
    if (!_nameRegex.hasMatch(v)) return 'Only letters, spaces, hyphens and apostrophes allowed';
    if (RegExp(r"\d").hasMatch(v)) return 'Name cannot contain numbers';
    return null;
  }

  static String? validateUsername(String? value, {int min = defaultUsernameMin, int max = defaultUsernameMax}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Username is required';
    if (v.length < min) return 'Username must be at least $min characters';
    if (v.length > max) return 'Username must be at most $max characters';
    if (!_usernameRegex.hasMatch(v)) {
      return 'Letters, numbers, dot, underscore, hyphen; no spaces';
    }
    if (v.contains('..') || v.contains('__') || v.contains('--') || v.contains('._') || v.contains('_.')) {
      return 'Avoid consecutive separators like .. or __';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value, {int min = defaultPasswordMin, int max = defaultPasswordMax}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    final issues = <String>[];
    if (v.length < min) issues.add('at least $min chars');
    if (v.length > max) issues.add('at most $max chars');
    if (!_hasLower.hasMatch(v)) issues.add('lowercase');
    if (!_hasUpper.hasMatch(v)) issues.add('uppercase');
    if (!_hasDigit.hasMatch(v)) issues.add('number');
    if (!_hasSymbol.hasMatch(v)) issues.add('symbol');
    if (v.contains(' ')) issues.add('no spaces');
    if (issues.isEmpty) return null;
    return 'Add ${issues.join(', ')}';
  }

  static String? validateConfirmPassword(String? value, String password) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }

  static ({double score, String label, int met}) passwordStrength(String password) {
    int categories = 0;
    if (_hasLower.hasMatch(password)) categories++;
    if (_hasUpper.hasMatch(password)) categories++;
    if (_hasDigit.hasMatch(password)) categories++;
    if (_hasSymbol.hasMatch(password)) categories++;

    double score = 0;
    score += (categories / 4) * 0.6;
    final len = password.length.clamp(0, 20);
    score += (len / 20) * 0.4;
    if (password.isEmpty) score = 0;

    String label;
    if (score < 0.2) {
      label = '';
    } else if (score < 0.4) {
      label = 'Weak';
    } else if (score < 0.6) {
      label = 'Fair';
    } else if (score < 0.8) {
      label = 'Strong';
    } else {
      label = 'Very Strong';
    }
    return (score: score, label: label, met: categories);
  }
}

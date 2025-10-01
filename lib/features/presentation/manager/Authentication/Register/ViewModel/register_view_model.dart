import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/login_response.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  final Register registerUseCase;

  AuthUser? _authUser;
  AuthUser? get authUser => _authUser;

  LoginResponse? _registerResponse;
  LoginResponse? get registerResponse => _registerResponse;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RegisterViewModel({
    required this.registerUseCase,
  });

  Future<void> register(String username, String password, String passwordConfirm, String email, String firstName, String lastName, String securityAnswer, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _registerResponse = await registerUseCase.execute(
        username, 
        password,
        passwordConfirm, 
        email,
        firstName,
        lastName,
        securityAnswer,
        role: role,
      );
      _authUser = _registerResponse!.data;
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Registration failed: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isApprovalPending => _registerResponse?.data.approved == false;
  
  String get registerMessage => _registerResponse?.message ?? '';
}

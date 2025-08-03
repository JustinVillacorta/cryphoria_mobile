import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final Login loginUseCase;

  AuthUser? _authUser;
  AuthUser? get authUser => _authUser;

  String? _error;
  String? get error => _error;

  LoginViewModel({required this.loginUseCase});

  Future<void> login(String username, String password) async {
    try {
      _authUser = await loginUseCase.execute(username, password);
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Login failed";
    }
    notifyListeners();
  }
}

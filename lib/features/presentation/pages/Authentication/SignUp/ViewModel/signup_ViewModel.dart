import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'package:flutter/foundation.dart';


class SignupViewModel extends ChangeNotifier {
  final Register registerUseCase;

  AuthUser? _authUser;
  AuthUser? get authUser => _authUser;

  String? _error;
  String? get error => _error;

  SignupViewModel({required this.registerUseCase});

  Future<void> signup(String username, String password, String email) async {
    try {
      _authUser = await registerUseCase.execute(username, password, email);
      _error = null;
    } catch (e) {
      _error = "Registration failed";
    }
    notifyListeners();
  }
}

  

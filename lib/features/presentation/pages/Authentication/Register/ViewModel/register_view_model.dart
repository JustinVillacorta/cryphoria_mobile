import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  final Register registerUseCase;

  AuthUser? _authUser;
  AuthUser? get authUser => _authUser;

  String? _error;
  String? get error => _error;

  RegisterViewModel({required this.registerUseCase});

  Future<void> register(
      String username, String password, String email) async {
    try {
      _authUser = await registerUseCase.execute(username, password, email);
      _error = null;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Registration failed";
    }
    notifyListeners();
  }
}

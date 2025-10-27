import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/data/data_sources/auth_local_data_source.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final Login loginUseCase;
  final AuthLocalDataSource authLocalDataSource;

  LoginViewModel({
    required this.loginUseCase,
    required this.authLocalDataSource,
  }) : super(LoginState.initial());

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      final loginResponse = await loginUseCase.execute(email, password);
      final authUser = loginResponse.data;

      state = state.copyWith(
        loginResponse: () => loginResponse,
        authUser: () => authUser,
        loginMessage: () => loginResponse.message,
      );

      await _verifyAuthenticationPersistence(authUser);

      state = state.copyWith(
        isLoading: false,
        error: () => null,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => "Login failed: ${e.toString()}",
      );
    }
  }

  Future<void> _verifyAuthenticationPersistence(AuthUser? authUser) async {
    try {
      debugPrint('🔍 LoginViewModel: Verifying authentication persistence...');

      await Future.delayed(const Duration(milliseconds: 200));

      final savedUser = await authLocalDataSource.getAuthUser();

      if (savedUser == null) {
        throw Exception('No authentication data found after login');
      }

      if (savedUser.token != authUser?.token) {
        throw Exception('Saved token does not match current token');
      }

      if (savedUser.firstName != authUser?.firstName) {
        throw Exception('Saved username does not match current username');
      }

      debugPrint('✅ LoginViewModel: Authentication persistence verified successfully');
      debugPrint('  - Username: ${savedUser.firstName}');
      debugPrint('  - Token length: ${savedUser.token.length}');
      debugPrint('  - Approved: ${savedUser.approved}');

    } catch (e) {
      debugPrint('🔥 LoginViewModel: Persistence verification failed: $e');

      try {
        debugPrint('🔄 LoginViewModel: Attempting to re-save authentication data...');
        await authLocalDataSource.cacheAuthUser(authUser!);

        await Future.delayed(const Duration(milliseconds: 100));
        final retrySavedUser = await authLocalDataSource.getAuthUser();

        if (retrySavedUser != null && retrySavedUser.token == authUser.token) {
          debugPrint('✅ LoginViewModel: Re-save successful');
        } else {
          throw Exception('Re-save verification failed');
        }

      } catch (retryError) {
        debugPrint('🔥 LoginViewModel: Re-save failed: $retryError');
        state = state.copyWith(
          error: () => 'Warning: Login successful but authentication may not persist across app restarts. Please contact support if you experience issues.',
        );
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

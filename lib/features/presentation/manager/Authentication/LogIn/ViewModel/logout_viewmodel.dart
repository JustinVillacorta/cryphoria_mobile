import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';
import 'package:cryphoria_mobile/features/data/data_sources/auth_local_data_source.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'logout_state.dart';

class LogoutViewModel extends StateNotifier<LogoutState> {
  final Logout logoutUseCase;
  final AuthLocalDataSource authLocalDataSource;

  LogoutViewModel({
    required this.logoutUseCase,
    required this.authLocalDataSource,
  }) : super(LogoutState.initial());

  Future<bool> logout() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
      );

      final success = await logoutUseCase.execute();

      if (success) {
        await authLocalDataSource.clearAuthData();
        state = state.copyWith(
          isLoading: false,
          isLoggedOut: true,
          message: () => 'Logout successful',
          error: () => null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: () => 'Logout failed',
          isLoggedOut: false,
        );
      }

      return success;
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
        isLoggedOut: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'An unexpected error occurred during logout',
        isLoggedOut: false,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeChangePasswordViewModel extends StateNotifier<AsyncValue<void>> {
  EmployeeChangePasswordViewModel(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {

    if (newPassword.isEmpty || currentPassword.isEmpty) {
      state = AsyncError('Please fill in all fields', StackTrace.current);
      return;
    }
    if (newPassword != confirmPassword) {
      state = AsyncError('New passwords do not match', StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(
        e.toString().replaceFirst('Exception: ', ''),
        st,
      );
    }
  }
}
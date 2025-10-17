import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:riverpod/riverpod.dart';


class ManagerChangePasswordViewModel extends StateNotifier<AsyncValue<void>> {
  ManagerChangePasswordViewModel(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('🔐 [MANAGER_VM] Change password request received');
    print('🔐 [MANAGER_VM] Current password length: ${currentPassword.length}');
    print('🔐 [MANAGER_VM] New password length: ${newPassword.length}');
    print('🔐 [MANAGER_VM] Confirm password length: ${confirmPassword.length}');
    
    if (newPassword.isEmpty || currentPassword.isEmpty) {
      print('🔐 [MANAGER_VM] ❌ Validation failed: Empty fields');
      state = AsyncError('Please fill in all fields', StackTrace.current);
      return;
    }
    if (newPassword != confirmPassword) {
      print('🔐 [MANAGER_VM] ❌ Validation failed: Passwords do not match');
      state = AsyncError('New passwords do not match', StackTrace.current);
      return;
    }
    
    print('🔐 [MANAGER_VM] ✅ Validation passed, setting loading state');
    state = const AsyncLoading();
    
    try {
      print('🔐 [MANAGER_VM] Calling auth repository...');
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      print('🔐 [MANAGER_VM] ✅ Repository call successful, setting success state');
      state = const AsyncData(null);
    } catch (e, st) {
      print('🔐 [MANAGER_VM] ❌ Repository call failed: $e');
      state = AsyncError(
        e.toString().replaceFirst('Exception: ', ''),
        st,
      );
    }
  }
}


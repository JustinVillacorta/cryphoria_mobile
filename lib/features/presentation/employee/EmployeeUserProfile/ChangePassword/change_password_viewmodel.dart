import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:riverpod/riverpod.dart';


class EmployeeChangePasswordViewModel extends StateNotifier<AsyncValue<void>> {
  EmployeeChangePasswordViewModel(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('🔐 [EMPLOYEE_VM] Change password request received');
    print('🔐 [EMPLOYEE_VM] Current password length: ${currentPassword.length}');
    print('🔐 [EMPLOYEE_VM] New password length: ${newPassword.length}');
    print('🔐 [EMPLOYEE_VM] Confirm password length: ${confirmPassword.length}');
    
    if (newPassword.isEmpty || currentPassword.isEmpty) {
      print('🔐 [EMPLOYEE_VM] ❌ Validation failed: Empty fields');
      state = AsyncError('Please fill in all fields', StackTrace.current);
      return;
    }
    if (newPassword != confirmPassword) {
      print('🔐 [EMPLOYEE_VM] ❌ Validation failed: Passwords do not match');
      state = AsyncError('New passwords do not match', StackTrace.current);
      return;
    }
    
    print('🔐 [EMPLOYEE_VM] ✅ Validation passed, setting loading state');
    state = const AsyncLoading();
    
    try {
      print('🔐 [EMPLOYEE_VM] Calling auth repository...');
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      print('🔐 [EMPLOYEE_VM] ✅ Repository call successful, setting success state');
      state = const AsyncData(null);
    } catch (e, st) {
      print('🔐 [EMPLOYEE_VM] ❌ Repository call failed: $e');
      state = AsyncError(
        e.toString().replaceFirst('Exception: ', ''),
        st,
      );
    }
  }
}

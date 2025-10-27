import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/core/error/exceptions.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';

class EditProfileState {
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? updatedUser;
  final bool isSuccess;

  EditProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.updatedUser,
    this.isSuccess = false,
  });

  EditProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthUser? updatedUser,
    bool? isSuccess,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      updatedUser: updatedUser ?? this.updatedUser,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final AuthRepository authRepository;

  EditProfileNotifier(this.authRepository) : super(EditProfileState());

  Future<AuthUser> updateProfileAndReturn({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String company,
    required String department,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {

      final updatedUser = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        company: company,
        department: department,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );


      state = state.copyWith(
        isLoading: false,
        updatedUser: updatedUser,
        isSuccess: true,
        errorMessage: null,
      );

      return updatedUser;
    } catch (e) {
      debugPrint('⚠️ EditProfileNotifier.updateProfileAndReturn: Error updating profile: $e');

      String errorMessage = 'Failed to update profile';
      if (e is ServerException) {
        errorMessage = e.message;
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'An unexpected error occurred';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isSuccess: false,
      );

      rethrow;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String company,
    required String department,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {

      final updatedUser = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        company: company,
        department: department,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );


      state = state.copyWith(
        isLoading: false,
        updatedUser: updatedUser,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('⚠️ EditProfileNotifier.updateProfile: Error updating profile: $e');

      String errorMessage = 'Failed to update profile';
      if (e is ServerException) {
        errorMessage = e.message;
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'An unexpected error occurred';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isSuccess: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetState() {
    state = EditProfileState();
  }
}

final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return EditProfileNotifier(authRepository);
});
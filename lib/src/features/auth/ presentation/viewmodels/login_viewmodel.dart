import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/repositories/auth_repository.dart";
import "../state/login_state.dart";

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository authRepository;

  LoginViewModel({
    required this.authRepository,
  }) : super(const LoginState());

  Future<void> restoreSession() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final session = await authRepository.getSavedSession();

      if (!session.hasValidLogin) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: session.userId,
        email: session.email,
        name: session.name,
        deviceId: session.deviceId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        error: "Failed to restore session: ${e.toString()}",
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: "Email and password are required",
        isLoggedIn: false,
      );
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
        isLoggedIn: false,
      );

      final response = await authRepository.login(
        email: email.trim(),
        password: password.trim(),
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Login successful",
        isLoggedIn: true,
        userId: response.user.id,
        email: response.user.email,
        name: response.user.name,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isLoggedIn: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Login failed: ${e.toString()}",
        isLoggedIn: false,
      );
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    state = const LoginState();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/services/auth/auth_admin_service.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AdminAuthService _authService;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> loginAdmin() async {
    emit(AuthLoading());

    try {
      if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
        emit(AuthFailure('Please enter your phone number and password.'));
        return;
      }
      bool success = await _authService.signInAdmin(
        phoneController.text.trim(),
        passwordController.text,
      );

      if (success) {
        await _authService.setAdminLoggedIn(true);
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Invalid credentials. Please try again.'));
      }
    } catch (e) {
      emit(AuthFailure('An error occurred. Please try again later.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.setAdminLoggedIn(false);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<bool> isAdminLoggedIn() async {
    return await _authService.isAdminLoggedIn();
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

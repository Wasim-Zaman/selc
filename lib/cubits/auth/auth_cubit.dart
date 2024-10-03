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
      bool success = await _authService.signInAdmin(
        phoneController.text.trim(),
        passwordController.text,
      );

      if (success) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Invalid credentials. Please try again.'));
      }
    } catch (e) {
      emit(AuthFailure('An error occurred. Please try again later.'));
    }
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

part of 'auth_cubit.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final bool isAdmin;
  AuthSuccess({this.isAdmin = false});
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}

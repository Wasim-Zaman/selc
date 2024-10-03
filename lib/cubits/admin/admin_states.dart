part of 'admin_cubit.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminSuccess extends AdminState {
  final String message;

  AdminSuccess(this.message);
}

class AdminFailure extends AdminState {
  final String error;

  AdminFailure(this.error);
}

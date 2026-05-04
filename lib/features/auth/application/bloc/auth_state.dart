import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? error;

  const Unauthenticated({this.error});

  @override
  List<Object?> get props => [error];
}

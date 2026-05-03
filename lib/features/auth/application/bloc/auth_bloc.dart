import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_validator.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  // ignore: unused_field
  final AuthValidator _validator;
  StreamSubscription? _sessionSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required AuthValidator validator,
  })  : _authRepository = authRepository,
        _validator = validator,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<_SessionChanged>(_onSessionChanged);
  }

  Future<void> _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _sessionSubscription?.cancel();
    _sessionSubscription = _authRepository.watchSession().listen((user) {
      add(_SessionChanged(user));
    });
  }

  void _onSessionChanged(_SessionChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(event.email, event.password);
      // Success will be handled by the session listener
    } catch (e) {
      emit(Unauthenticated(error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}

class _SessionChanged extends AuthEvent {
  final User? user;
  const _SessionChanged(this.user);

  @override
  List<Object?> get props => [user];
}


import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incauca_labs/features/auth/data/cache/local_user_draft.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';
import 'package:incauca_labs/features/auth/domain/entities/user_profile.dart';
import 'package:incauca_labs/features/auth/domain/services_def/auth_service_def.dart';
import 'package:incauca_labs/features/auth/domain/services_def/user_service_def.dart';


part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthenticationService _authenticationService;
  final UserService _userService;

  AppBloc({
    required AuthenticationService authenticationService,
    required UserService userService,
  })  : _authenticationService = authenticationService,
        _userService = userService,
        super(AppState(user: AppUser.empty)) {

    print('🟦 [AppBloc] Inicializado. Estado inicial = AppUser.empty');

    on<AppUserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<AppLogoutPressed>(_onLogoutPressed);
    on<AppProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onUserSubscriptionRequested(
    AppUserSubscriptionRequested event,
    Emitter<AppState> emit,
  ) async {
    print('🟨 [Event] AppUserSubscriptionRequested recibido');
    print('🔎 [AppBloc] Consultando firebase.getCurrentUser()...');

    try {
      final firebaseUser = await _authenticationService.getCurrentUser();
      final user = AppUser.fromFirebaseUser(firebaseUser);

      print('📥 [Firebase] Usuario actual: '
          '${user == AppUser.empty ? "VACÍO" : user.uid}');

      if (user != AppUser.empty) {
        print('🟢 [AppBloc] Usuario válido detectado -> buscando profile...');

        final draft = await LocalUserDraft.load();

        if (draft != null) {
          print('📄 [Draft] Perfil local encontrado → usando draft');
          emit(
            state.copyWith(user: user, profile: draft),
          );
          print(
            '🟩 [State] Estado emitido (con draft). user=${user.uid}, profile=draft',
          );
          return;
        }

        print('🌐 [API] Buscando perfil remoto para uid=${user.uid}');
        final profile = await _userService.getUserProfile(user.uid);

        emit(
          state.copyWith(
            user: user,
            profile: profile ?? UserProfile.empty,
          ),
        );
        print(
          '🟩 [State] Estado emitido (perfil remoto). user=${user.uid}',
        );
      } else {
        print('🔴 [AppBloc] No hay usuario → limpiando estado');
        emit(
          state.copyWith(
            user: AppUser.empty,
            profile: UserProfile.empty,
          ),
        );
        print('⬜ [State] Estado emitido = vacío');
      }
    } catch (e) {
      print('❌ [AppBloc] Error en suscripción: $e');
      emit(state.copyWith(user: AppUser.empty));
    }
  }

  Future<void> _onLogoutPressed(
    AppLogoutPressed event,
    Emitter<AppState> emit,
  ) async {
    print('🚪 [Event] AppLogoutPressed recibido');

    await _authenticationService.logOut();
    print('🧽 [Logout] Sesión cerrada → limpiando estado');

    emit(const AppState(user: AppUser.empty, profile: UserProfile.empty));
    print('⬜ [State] Estado emitido = vacío');
  }

  Future<void> _onProfileRefreshRequested(
    AppProfileRefreshRequested event,
    Emitter<AppState> emit,
  ) async {
    print('🔄 [Event] AppProfileRefreshRequested recibido');
    print('🔎 [AppBloc] Consultando firebase.getCurrentUser()...');

    final firebaseUser = await _authenticationService.getCurrentUser();
    final user = AppUser.fromFirebaseUser(firebaseUser);

    if (user == AppUser.empty) {
      print('🔴 [Profile] No hay usuario → cancelando refresh');
      return;
    }

    print('🟢 [Profile] Usuario válido → refrescando perfil');

    final draft = await LocalUserDraft.load();

    if (draft != null) {
      print('📄 [Draft] Perfil local encontrado');
      emit(state.copyWith(user: user, profile: draft));
      print('🟩 [State] Estado emitido (con draft)');
      return;
    }

    final profile = await _userService.getUserProfile(user.uid);
    emit(state.copyWith(user: user, profile: profile ?? UserProfile.empty));
    print('🟩 [State] Estado emitido (perfil remoto)');
  }
}

import 'package:go_router/go_router.dart';
import 'package:incauca_labs/app/router/refresh_stream.dart';
import 'package:incauca_labs/app/state/app_bloc.dart';
import 'package:incauca_labs/features/auth/application/home/view/home_view.dart';
import 'package:incauca_labs/features/auth/application/login/view/login_page.dart';
import 'package:incauca_labs/features/auth/application/start/view/start_view.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

class AppRouter {
  static GoRouter create(AppBloc appBloc) {
    print('🟦 [Router] Creando GoRouter');

    return GoRouter(
      initialLocation: '/start',

      // 👉 Esto hace que el router ESCUCHE los cambios del Bloc
      refreshListenable: GoRouterRefreshStream(appBloc.stream),

      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ],

      redirect: (_, state) {
        final user = appBloc.state.user;
        final isLoggedIn = user != AppUser.empty;

        final goingTo = state.uri.toString();
        final isOnLogin = goingTo == '/login' || goingTo == '/start';

        // 🟨 Log del redirect SIEMPRE se ejecuta cuando cambia el Bloc
        print(
          '🧭 [Redirect] location=$goingTo | user=${isLoggedIn ? user.uid : "VACIO"}',
        );

        // 🚫 Usuario NO logueado
        if (!isLoggedIn) {
          print('🔴 [Redirect] Usuario NO logueado');
          if (!isOnLogin) {
            print('➡️ [Redirect] REDIRIGIENDO a /start');
            return '/start';
          }
          print('✔️ [Redirect] Permitir navegación a pantalla pública');
          return null;
        }

        // 🟢 Usuario logueado
        print('🟢 [Redirect] Usuario logueado');

        if (isOnLogin) {
          print('➡️ [Redirect] Usuario logueado entrando a login → REDIRIGIENDO a /home');
          return '/home';
        }

        print('✔️ [Redirect] Permitir navegación normal');
        return null;
      },
    );
  }
}

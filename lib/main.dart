import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incauca_labs/core/theme.dart';
import 'core/service_locator.dart';
import 'package:incauca_labs/features/filters/list/views/filter_list_view.dart';
import 'features/auth/application/bloc/auth_bloc.dart';
import 'features/auth/application/bloc/auth_event.dart';
import 'features/auth/application/bloc/auth_state.dart';
import 'features/auth/application/views/sign_in_view.dart';
import 'features/filters/notifications/bloc/notifications_bloc.dart';
import 'features/filters/notifications/bloc/notifications_event.dart';
import 'features/filters/notifications/bloc/notifications_state.dart';
import 'features/filters/detail/views/filter_detail_view.dart';
import 'firebase_options.dart';

import 'core/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppConfig.initialize();
  setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(AuthStarted()),
        ),
        BlocProvider(
          create: (context) => getIt<NotificationsBloc>()..add(NotificationsStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'SIVIA',
        theme: lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (previous, current) =>
          current.notifications.length > previous.notifications.length,
      listener: (context, state) {
        final lastResult = state.notifications.first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nuevos resultados disponibles (#${lastResult.id})'),
            action: SnackBarAction(
              label: 'VER',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterDetailView(detail: lastResult),
                  ),
                );
              },
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const FilterListView();
          } else if (state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Both Unauthenticated and AuthLoading should show the SignInView.
            // The SignInView handles its own loading state internally (disabling the button, showing a loader).
            // Keeping it in the tree here prevents the email/password fields from being wiped.
            return const SignInView();
          }
        },
      ),
    );
  }
}

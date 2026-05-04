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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const FilterListView();
        } else if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const SignInView();
        }
      },
    );
  }
}

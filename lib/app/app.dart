import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incauca_labs/features/auth/data/datasources_impl/authentication_datasource_impl.dart';
import 'package:incauca_labs/features/auth/data/datasources_impl/cosmosdbClient.dart';
import 'package:incauca_labs/features/auth/data/datasources_impl/user_datasource_impl.dart';
import 'package:incauca_labs/features/auth/data/services_impl/auth_service_impl.dart';
import 'package:incauca_labs/features/auth/data/services_impl/user_service_impl.dart';
import 'package:incauca_labs/features/auth/domain/datasources_def/authentication_datasource_def.dart';
import 'package:incauca_labs/features/auth/domain/datasources_def/user_datasource_def.dart';
import 'package:incauca_labs/features/auth/domain/services_def/auth_service_def.dart';
import 'package:incauca_labs/features/auth/domain/services_def/user_service_def.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:incauca_labs/app/constants/theme.dart';
import 'package:incauca_labs/app/router/app_router.dart';
import 'package:incauca_labs/app/state/app_bloc.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationDataSource>(
          create:
              (_) => AuthenticationDataSourceImpl(
                firebaseAuth: FirebaseAuth.instance,
              ),
        ),
        Provider<UserDataSource>(
          create:
              (_) => UserDataSourceImpl(
                client: CosmosDBClient(
                  endpoint:
                      'https://incauca-cosmos-db-account-36104.documents.azure.com:443/',
                  databaseId: 'incauca-cosmosdb-database',
                  containerId: 'incauca-cosmosdb-container',
                  masterKey:
                      'sQlZs4yIkQ2rPbbbqtVxfsokrDiHkSGfRmSgxIi0PvKXxcL7w3bw0xrWr9jNkHDRvMMpwok5K3zVACDb0DtSIQ==',
                ),
              ),
        ),

        Provider<AuthenticationService>(
          create:
              (context) => AuthenticationServiceImpl(
                authService: context.read<AuthenticationDataSource>(),
              ),
        ),
        Provider<UserService>(
          create:
              (context) => UserServiceImpl(
                authService: context.read<AuthenticationService>(),
                userDataSource: context.read<UserDataSource>(),
              ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appBloc = AppBloc(
            authenticationService: context.read<AuthenticationService>(),
            userService: context.read<UserService>(),
          )..add(const AppUserSubscriptionRequested());
          print('🟦 [AppProvider] AppBloc creado y AppUserSubscriptionRequested enviado');


          final router = AppRouter.create(appBloc);

          return BlocProvider.value(
            value: appBloc,
            child: AppView(router: router),
          );
        },
      ),
    );
  }
}

class AppView extends StatelessWidget {
  final GoRouter router;

  const AppView({required this.router, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

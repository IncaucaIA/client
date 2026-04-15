import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incauca_labs/core/theme.dart';
import 'core/service_locator.dart';
import 'filters/upload/application/bloc/upload_bloc.dart';
import 'filters/upload/application/upload_view.dart';

import 'core/config.dart';

void main() {
  AppConfig.initialize();
  setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIVIA',
      theme: lightTheme,
      home: BlocProvider(
        create: (context) => getIt<UploadBloc>(),
        child: const UploadView(),
      ),
    );
  }
}

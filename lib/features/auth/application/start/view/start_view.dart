import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:incauca_labs/features/auth/application/shared/widgets/auth_button.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: StartPage());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Welcome text
              _WelcomeText(),
              
              const SizedBox(height: 32),
              
              // Auth buttons
              _AuthButtons(),
              
    
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text('SIVIA',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Más que un Análisis",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AuthButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AuthButton(
            text: 'Login',
            onPressed: () => context.go('/login'),
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AuthButton(
            text: 'Register',
            onPressed: () => context.go('/register'),
            isPrimary: true,
          ),
        ),
      ],
    );
  }
}
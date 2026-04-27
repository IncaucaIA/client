import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:incauca_labs/app/state/app_bloc.dart';
import 'package:incauca_labs/features/auth/application/login/state/login_bloc.dart';
import 'package:incauca_labs/features/auth/application/shared/widgets/custom_input_field.dart';
import 'package:incauca_labs/features/auth/application/shared/widgets/form_action_button.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

class LoginFormContent extends StatelessWidget {
  const LoginFormContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'Error al iniciar sesión',
                      style: TextStyle(color: colorScheme.onError),
                    ),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
            }
            if (state.status.isSuccess) {
              context.read<AppBloc>().add(const AppUserSubscriptionRequested());
            }
          },
        ),
      ],
      child: Column(
        children: [
          const _EmailInput(),
          const SizedBox(height: 16),
          const _PasswordInput(),
          const SizedBox(height: 24),
          const _LoginButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = context.select((LoginBloc bloc) => bloc.state.email);
    final showError = email.isNotValid && !email.isPure;

    return CustomInputField(
      key: const Key('LoginForm_emailInput_textField'),
      label: 'Correo electrónico',
      hintText: 'Ingresa tu correo',
      prefixIcon: Icons.email_outlined,
      errorText: showError ? email.error?.message : null,
      keyboardType: TextInputType.emailAddress,
      onChanged: (email) => context.read<LoginBloc>().add(EmailChanged(email)),
      theme: theme,
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput();

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final password = context.select((LoginBloc bloc) => bloc.state.password);
    final showError = password.isNotValid && !password.isPure;

    return CustomInputField(
      key: const Key('LoginForm_passwordInput_textField'),
      label: 'Contraseña',
      hintText: 'Ingresa tu contraseña',
      prefixIcon: Icons.lock_outline,
      errorText: showError ? password.error?.message : null,
      obscureText: _obscureText,
      onChanged: (password) =>
          context.read<LoginBloc>().add(PasswordChanged(password)),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      theme: theme,
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final isInProgress = context.select(
      (LoginBloc bloc) => bloc.state.status.isInProgress,
    );

    final isValid = context.select((LoginBloc bloc) => bloc.state.isValid);

    return FormActionButton(
      buttonKey: const Key('LoginForm_continue_raisedButton'),
      text: 'Iniciar sesión',
      isInProgress: isInProgress,
      isValid: isValid,
      onPressed: () =>
          context.read<LoginBloc>().add(LogInWithCredentials()),
    );
  }
}

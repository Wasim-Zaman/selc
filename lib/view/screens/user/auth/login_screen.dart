// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigations.pushReplacement(context, DashboardScreen());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 80),
              Image.asset(
                AppIcons.selcLogo,
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to continue with your account',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 50),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () async {
                            await context.read<AuthCubit>().signInWithGoogle();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 3,
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                theme.brightness == Brightness.dark
                                    ? AppIcons.signinDark
                                    : AppIcons.siginLight,
                                height: 24.0,
                                width: 24.0,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign in with Google',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

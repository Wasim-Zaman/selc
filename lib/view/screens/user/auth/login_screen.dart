// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/router/app_navigation.dart';
import 'package:selc/router/app_routes.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && !state.isAdmin) {
          TopSnackbar.success(context, 'Login successful');
          AppNavigation.goAndClearStack(context, AppRoutes.kDashboardRoute);
        } else if (state is AuthFailure) {
          TopSnackbar.error(context, state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const SizedBox.shrink(),
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
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          AppIcons.selcLogo,
                          height: 200,
                          width: 200,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sign in to continue with your account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 50),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()
                              ..scale(state is AuthLoading ? 0.95 : 1.0),
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () async {
                                      await context
                                          .read<AuthCubit>()
                                          .signInWithGoogle();
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          isDark
                                              ? AppIcons.signinDark
                                              : AppIcons.siginLight,
                                          height: 24.0,
                                          width: 24.0,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Sign in with Google',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

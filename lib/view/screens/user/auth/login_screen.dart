// ignore_for_file: use_build_context_synchronously

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_button.dart';

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
          child: AppScaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
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
                          isDark ? AppIcons.gepLogoDark : AppIcons.gepLogoLight,
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
                            child: AppButton(
                              label: 'Sign in with Google',
                              onPressed: state is AuthLoading
                                  ? null
                                  : () async {
                                      await context
                                          .read<AuthCubit>()
                                          .signInWithGoogle();
                                    },
                              isLoading: state is AuthLoading,
                              icon: Image.asset(
                                isDark
                                    ? AppIcons.signinDark
                                    : AppIcons.siginLight,
                                height: 24.0,
                                width: 24.0,
                              ),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                              borderRadius: 8,
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

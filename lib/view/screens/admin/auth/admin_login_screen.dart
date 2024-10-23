import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Builder(
      builder: (context) {
        final authCubit = context.read<AuthCubit>();
        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              TopSnackbar.success(context, 'Login successful');
              Navigations.push(context, const AdminDashboardScreen());
            } else if (state is AuthFailure) {
              TopSnackbar.error(context, state.errorMessage);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Admin Login', style: theme.textTheme.headlineSmall),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      Image.asset(
                        AppIcons.selcLogo,
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Admin Login',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your credentials to access the admin dashboard',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFieldWidget(
                        controller: authCubit.phoneController,
                        labelText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: authCubit.passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            Navigations.push(
                              context,
                              const AdminDashboardScreen(),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AuthFailure) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                state.errorMessage,
                                style:
                                    TextStyle(color: theme.colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => authCubit.loginAdmin(),
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
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

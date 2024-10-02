import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:selc/services/auth/auth_service.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current theme information
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Logo (Optional)
            const SizedBox(height: 80),
            const FlutterLogo(
              size: 100,
            ),
            const SizedBox(height: 40),

            // Welcome Text
            const Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to continue with your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? AppColors.darkBodyTextSecondary
                    : AppColors.lightBodyTextSecondary, // Adapt to theme
              ),
            ),
            const SizedBox(height: 50),

            // Google Sign-In Button
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  print('User signed in: ${user.displayName}');
                  // Navigate to home or perform other actions
                  Navigations.pushReplacement(context, const DashboardScreen());
                } else {
                  print('Sign in failed or was canceled.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? AppColors.darkButton : AppColors.lightButton,
                foregroundColor:
                    isDarkMode ? AppColors.darkIcon : AppColors.lightIcon,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    isDarkMode
                        ? AppIcons.signinDark // Use dark theme image
                        : AppIcons.siginLight, // Use light theme image
                    height: 24.0,
                    width: 24.0,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkBodyText
                          : AppColors.lightBodyText, // Adapt text to theme
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Footer Text
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppColors.darkBodyTextSecondary
                    : AppColors.lightBodyTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

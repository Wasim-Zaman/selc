import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart'; // Assume AppIcons is defined here

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current theme information
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    ? Colors.white70
                    : Colors.black54, // Adapt to theme
              ),
            ),
            const SizedBox(height: 50),

            // Google Sign-In Button
            ElevatedButton(
              onPressed: () {
                // TODO: Add Google sign-in logic here
                Navigations.pushReplacement(context, DashboardScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: isDarkMode ? Colors.white70 : Colors.grey),
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
                          ? Colors.white
                          : Colors.black, // Adapt text to theme
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
                    ? Colors.white70
                    : Colors.black45, // Adapt to theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}

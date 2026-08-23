import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

/// Reusable, animated navigation drawer used across the app.
///
/// [isAdminLoggedIn] is passed in rather than resolved internally,
/// since the caller already knows how to check that (e.g. via a
/// FutureBuilder / cubit call in initState).
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.isAdminLoggedIn,
  });

  final bool isAdminLoggedIn;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(user: user, theme: theme),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    index: 0,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: profile navigation
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    index: 1,
                    onTap: () {
                      Navigator.pop(context);
                      if (isAdminLoggedIn) {
                        AppNavigation.pushReplacement(
                          context,
                          AppRoutes.kAdminDashboardRoute,
                        );
                      } else {
                        AppNavigation.push(
                          context,
                          AppRoutes.kAdminLoginRoute,
                        );
                      }
                    },
                  ),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeMode) {
                      final isDark = themeMode == ThemeMode.dark;
                      return _DrawerTile(
                        icon: isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        label: isDark ? 'Light Mode' : 'Dark Mode',
                        index: 2,
                        onTap: () => context.read<ThemeCubit>().toggleTheme(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _DrawerTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                index: 3,
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () async {
                  context.pop();
                  await context.read<AuthCubit>().logout();
                  if (!context.mounted) return;
                  AppNavigation.goAndClearStack(
                    context,
                    AppRoutes.kLoginRoute,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user, required this.theme});

  final User? user;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user?.photoURL ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'Guest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.index,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final int index;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
          title: Text(
            label,
            style: TextStyle(
              color: textColor ?? theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 * index).ms, duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

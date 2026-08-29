import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.isAdminLoggedIn});

  final bool isAdminLoggedIn;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerHeader(user: user, isAdminLoggedIn: isAdminLoggedIn),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const _SectionHeader(label: 'Account'),
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
                        AppNavigation.push(context, AppRoutes.kAdminLoginRoute);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader(label: 'Preferences'),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeMode) {
                      final isDark = themeMode == ThemeMode.dark;
                      return _DrawerTile(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        label: isDark ? 'Light Mode' : 'Dark Mode',
                        index: 2,
                        onTap: () => context.read<ThemeCubit>().toggleTheme(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _LogoutTile(
                index: 3,
                onTap: () async {
                  context.pop();
                  await context.read<AuthCubit>().logout();
                  if (!context.mounted) return;
                  AppNavigation.goAndClearStack(context, AppRoutes.kLoginRoute);
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
  const _DrawerHeader({required this.user, required this.isAdminLoggedIn});

  final User? user;
  final bool isAdminLoggedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final displayName = user?.displayName ?? 'Guest User';
    final email = user?.email ?? 'Sign in to continue';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
                child: ClipOval(
                  child: user?.photoURL != null
                      ? CachedNetworkImage(
                          imageUrl: user!.photoURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_rounded,
                            color: colorScheme.onPrimaryContainer,
                            size: 30,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: isDark
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onPrimaryContainer,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isAdminLoggedIn
                      ? colorScheme.primary
                      : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdminLoggedIn ? 'Admin' : 'Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, end: 0);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6, top: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.index,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: Icon(icon, size: 22, color: colorScheme.secondary),
            title: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: onTap,
          ),
        )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 250.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.index, required this.onTap});

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

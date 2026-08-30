import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/about_me.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensures Material localizations are always available even if parent context loses them
    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('About Me'), centerTitle: true),
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminFailure) {
              TopSnackbar.error(context, state.error);
            }
          },
          builder: (context, state) {
            return StreamBuilder<AboutMe>(
              stream: context.read<AdminCubit>().getAboutMeStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load details',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final aboutMe = snapshot.data ?? AboutMe();
                final colors = Theme.of(context).colorScheme;
                final theme = Theme.of(context);

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: colors.primaryContainer,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: aboutMe.profileImageUrl ?? '',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sana Ullah',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Instructor',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Map Action Tile
                    _buildActionTile(
                      context: context,
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.redAccent,
                      title: 'Institute Location',
                      subtitle: 'Tap to view on Google Maps',
                      onTap: () => _launchMaps(
                        context,
                        aboutMe.latitude,
                        aboutMe.longitude,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Resume Action Tile
                    _buildActionTile(
                      context: context,
                      icon: Icons.picture_as_pdf_outlined,
                      iconColor: colors.primary,
                      title: 'Resume / CV',
                      subtitle: aboutMe.resumeUrl != null
                          ? 'Tap to open document'
                          : 'No document uploaded',
                      onTap: aboutMe.resumeUrl != null
                          ? () => AppNavigation.push(
                              context,
                              AppRoutes.kFullScreenResumeRoute,
                              extra: aboutMe.resumeUrl!,
                            )
                          : null,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onTap != null;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: enabled
                            ? colors.onSurface
                            : colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _launchMaps(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        TopSnackbar.error(context, "Could not open the map");
      }
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/about_me.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/screens/user/dashboard/about_me/full_screen_resume_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/youtube_channel_screen.dart';
import 'package:selc/view/widgets/grid_item.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  IconData getFallbackIcon(String title) {
    switch (title) {
      case 'Institute Location':
        return Icons.location_on;
      case 'YouTube Channel':
        return Icons.play_circle;
      default:
        return Icons.dashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('About Me', style: theme.textTheme.headlineSmall),
      ),
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
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final aboutMe = snapshot.data ?? AboutMe();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileSection(context, aboutMe),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildGridItems(context, aboutMe),
                      // const SizedBox(height: AppConstants.defaultPadding),
                      // _buildMapSection(aboutMe),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildResumeSection(aboutMe, context),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AboutMe aboutMe) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Hero(
              tag: 'profile_image',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: aboutMe.profileImageUrl != null
                      ? CachedNetworkImageProvider(
                          aboutMe.profileImageUrl ?? "")
                      : const CachedNetworkImageProvider(
                          "https://via.placeholder.com/150"),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Sana Ullah',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Instructor',
              style: theme.textTheme.titleMedium?.copyWith(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItems(BuildContext context, AboutMe aboutMe) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return GridItem(
          title: gridItems[index]['title'],
          screen: gridItems[index]['screen'],
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          lottieUrl: gridItems[index]['lottieUrl'],
          onTap: () => _handleGridItemTap(context, index, aboutMe),
          fallbackIcon: getFallbackIcon(gridItems[index]['title']),
        );
      },
    );
  }

  void _handleGridItemTap(BuildContext context, int index, AboutMe aboutMe) {
    switch (gridItems[index]['title']) {
      case 'Institute Location':
        _launchMaps(context, aboutMe.latitude, aboutMe.longitude);
        break;
      case 'YouTube Channel':
        Navigations.push(
          context,
          YouTubeChannelScreen(url: aboutMe.youtubeChannelLink),
        );
        break;
    }
  }

  // Widget _buildMapSection(AboutMe aboutMe) {
  //   return Container(
  //     height: 200,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.0),
  //       border: Border.all(color: Colors.grey),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12.0),
  //       child: GoogleMap(
  //         initialCameraPosition: CameraPosition(
  //           target: LatLng(aboutMe.latitude, aboutMe.longitude),
  //           zoom: 15,
  //         ),
  //         markers: {
  //           Marker(
  //             markerId: const MarkerId('institute'),
  //             position: LatLng(aboutMe.latitude, aboutMe.longitude),
  //           ),
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildResumeSection(AboutMe aboutMe, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: aboutMe.resumeUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resume',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          onPressed: () => _openFullScreenResume(
                              context, aboutMe.resumeUrl!),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SfPdfViewer.network(
                      aboutMe.resumeUrl ?? "",
                      scrollDirection: PdfScrollDirection.horizontal,
                      interactionMode: PdfInteractionMode.pan,
                      enableDoubleTapZooming: true,
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No resume available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _openFullScreenResume(BuildContext context, String resumeUrl) {
    Navigations.push(
      context,
      FullScreenResumeScreen(resumeUrl: resumeUrl),
    );
  }

  void _launchMaps(
      BuildContext context, double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // ignore: use_build_context_synchronously
      TopSnackbar.error(context, "Could not open the map");
    }
  }
}

final List<Map<String, dynamic>> gridItems = [
  {
    'title': 'Institute Location',
    'lottieUrl': AppLotties.location,
  },
  {
    'title': 'YouTube Channel',
    'lottieUrl': AppLotties.youtube,
  },
];

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/banner/banner_cubit.dart';
import 'package:selc/cubits/banner/banner_state.dart';
import 'package:selc/utils/constants.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        // if (state is BannerLoading) {
        //   return PlaceholderWidgets.bannerPlaceholder();
        // }

        if (state is BannerLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: AspectRatio(
                aspectRatio: 2,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: false,
                    scrollPhysics: const ClampingScrollPhysics(),
                  ),
                  items: state.banners.map((banner) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: banner.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.lightNeutral,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.lightNeutral,
                                child: Icon(
                                  Icons.error,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            // Optional: Add a subtle gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

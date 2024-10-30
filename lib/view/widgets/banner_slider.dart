import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/banner/banner_cubit.dart';
import 'package:selc/cubits/banner/banner_state.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        if (state is BannerLoading) {
          return const AspectRatio(
            aspectRatio: 2.5,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BannerLoaded) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 2.5,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 0.8,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      context.read<BannerCubit>().updateCurrentIndex(index);
                    },
                  ),
                  items: state.banners.map((banner) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image:
                                  CachedNetworkImageProvider(banner.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: state.banners.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(
                            state.currentIndex == entry.key ? 0.9 : 0.4,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

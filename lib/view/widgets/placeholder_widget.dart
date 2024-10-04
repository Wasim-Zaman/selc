import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

class PlaceholderWidgets {
  static Widget rectanglePlaceholder({
    double width = double.infinity,
    double height = 100,
    double borderRadius = 8,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
    );
  }

  static Widget textPlaceholder({
    double width = 200,
    double height = 16,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            width: width,
            height: height,
            color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          ),
        );
      },
    );
  }

  static Widget listPlaceholder({int itemCount = 5}) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              rectanglePlaceholder(width: 60, height: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textPlaceholder(),
                    const SizedBox(height: 8),
                    textPlaceholder(width: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget gridPlaceholder({int itemCount = 6}) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return rectanglePlaceholder(height: 120);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:selc/utils/navigation.dart';

class LearningResourcesSection extends StatelessWidget {
  final List<Map<String, dynamic>> resources;

  const LearningResourcesSection({
    Key? key,
    required this.resources,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Learning Resources',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () =>
                        Navigations.push(context, resources[index]['screen']),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: resources[index]['gradient'],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Lottie.asset(
                                resources[index]['lottieUrl'],
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              resources[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

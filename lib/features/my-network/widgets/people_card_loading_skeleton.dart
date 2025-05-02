import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GrowTabPeopleCardLoadingSkeleton extends ConsumerWidget {
  const GrowTabPeopleCardLoadingSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
        enabled: true,
        child: Card(
          shadowColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              width: 0.5,
            ),
          ),
          child: Column(
            spacing: 15,
            children: [
              Stack(
                clipBehavior: Clip.none, // Important to allow overflow
                alignment: Alignment
                    .bottomCenter, // Align profile pic to bottom center
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    child: Image(
                      image:
                          AssetImage('assets/images/default-cover-picture.png'),
                      width: double.infinity,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Profile image - positioned to overlap
                  Positioned(
                    bottom: -25,
                    right: 32,
                    child: CircleAvatar(
                      radius: 45,
                      foregroundImage: AssetImage(
                          'assets/images/default-profile-picture.png'),
                    ),
                  ),
                  // Cancel Button
                  Positioned(
                    top: 5,
                    right: 3,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(),
              Column(
                children: [
                  Text(
                    "Amanda Williams",
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.0,
                    ),
                    child: Text(
                      'AI Engineer @ OpenAI',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: null,
                      child: Text("Connect"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ConnectionsCardLoadingSkeleton extends ConsumerWidget {
  const ConnectionsCardLoadingSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          border: Border(
            bottom: BorderSide(
              width: 0.3,
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 30,
                    foregroundImage: const AssetImage(
                        'assets/images/default-profile-picture.png'),
                  ),
                  // Text content
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      SizedBox(
                        child: Text(
                          "Full Name",
                        ),
                      ),
                      // Title
                      SizedBox(
                        child: Text(
                          "Professional title of the person",
                        ),
                      ),
                      // Date
                      SizedBox(
                        child: Text(
                          "Sent 2 days ago",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Remove & Message buttons
              Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.remove,
                    size: 30,
                  ),
                  Icon(
                    Icons.send,
                    size: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

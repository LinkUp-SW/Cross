import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReceivedInvitationsLoadingSkeleton extends ConsumerWidget {
  final bool isDarkMode;

  const ReceivedInvitationsLoadingSkeleton({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Skeletonizer(
      enabled: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          border: Border(
            bottom: BorderSide(
              width: 0.3.w,
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10.w,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8.w,
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 30.r,
                    foregroundImage: const AssetImage(
                        'assets/images/default-profile-picture.jpg'),
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
                      // Mutual connections
                      SizedBox(
                        child: Text(
                          "64 mutual connections",
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
              // Accept & ignore buttons
              Row(
                spacing: 8.w,
                children: [
                  Icon(
                    Icons.circle,
                    size: 30.r,
                  ),
                  Icon(
                    Icons.circle,
                    size: 30.r,
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

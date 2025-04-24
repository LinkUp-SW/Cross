import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GrowTabPeopleCardLoadingSkeleton extends ConsumerWidget {
  final bool isDarkMode;

  const GrowTabPeopleCardLoadingSkeleton({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Skeletonizer(
        enabled: true,
        child: Card(
          shadowColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          elevation: 3.0.r,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
            side: BorderSide(
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              width: 0.5.w,
            ),
          ),
          child: Column(
            spacing: 15.h,
            children: [
              Stack(
                clipBehavior: Clip.none, // Important to allow overflow
                alignment: Alignment
                    .bottomCenter, // Align profile pic to bottom center
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r),
                    ),
                    child: Image(
                      image:
                          AssetImage('assets/images/default-cover-picture.png'),
                      width: double.infinity,
                      height: 60.h,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Profile image - positioned to overlap
                  Positioned(
                    bottom: -25.h,
                    right: 32.w,
                    child: CircleAvatar(
                      radius: 45.r,
                      foregroundImage: AssetImage(
                          'assets/images/default-profile-picture.jpg'),
                    ),
                  ),
                  // Cancel Button
                  Positioned(
                    top: 5.h,
                    right: 3.w,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.h,
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
                      horizontal: 6.0.w,
                    ),
                    child: Text(
                      'AI Engineer @ OpenAI',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
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

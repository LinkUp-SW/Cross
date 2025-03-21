import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  const ProfileHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _uploadBackgroundImage,
                child: Container(
                  height: 70.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 30.h,
                left: 0,
                right: 270,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48.r,
                          backgroundImage: AssetImage('assets/images/uploadProfilePic.png'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10.r,
                          backgroundColor: AppColors.lightBlue,
                          child: Icon(Icons.add, size: 14.sp, color: AppColors.lightMain),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 60.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Amr Safwat",
                  style: TextStyles.font25_700Weight.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                ),
                Text(
                  "Student at Cairo University",
                  style: TextStyles.font18_500Weight.copyWith(
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
                Text(
                  "Cairo University, Giza, Al Jizah, Egypt",
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                Text(
                  "0 connections",
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: buttonStyles.wideBlueElevatedButton(),
                        child: const Text("Open to"),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: buttonStyles.blueOutlinedButton(),
                        child: Text("Add section", style: TextStyle(color: AppColors.lightBlue)),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightTextColor, width: 2.r),
                        color: Colors.transparent,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_horiz, color: AppColors.lightTextColor),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: buttonStyles.blueOutlinedButton(),
                    child: Text("Enhance profile", style: TextStyle(color: AppColors.lightBlue)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _uploadBackgroundImage() {
    // Handle background image upload
  }
}

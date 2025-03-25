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
                      icon: Icon(Icons.camera_alt_rounded, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 30.h,
                left: 16.w,
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
              Positioned(
                top: 70.h,
                right: 16.w,
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.edit,
                    color: AppColors.lightSecondaryText,
                    size: 20.sp,
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
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                  ),
                ),
                SizedBox(height: 5.h),

                Text(
                  "Cairo University",
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                Text(
                  "Giza, Al Jizah, Egypt",
                  style: TextStyles.font13_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 10.h),
                Text(
                  "0 connections",
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 8.h),
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
                        style: isDarkMode 
                            ? buttonStyles.wideBlueElevatedButtonDark()
                            : buttonStyles.wideBlueElevatedButton(),
                        child: Text(
                          "Open to",
                          style: TextStyles.font15_500Weight.copyWith(
                            color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: isDarkMode 
                            ? buttonStyles.blueOutlinedButtonDark()
                            : buttonStyles.blueOutlinedButton(),
                        child: Text(
                          "Add section",
                          style: TextStyles.font15_500Weight.copyWith(
                            color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SizedBox(
                      width: 30.r,
                      height: 35.r,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: isDarkMode 
                            ? buttonStyles.circularButtonDark()
                            : buttonStyles.circularButton(),
                        child: Icon(
                          Icons.more_horiz,
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: isDarkMode 
                        ? buttonStyles.blueOutlinedButtonDark()
                        : buttonStyles.blueOutlinedButton(),
                    child: Text(
                      "Enhance profile",
                      style: TextStyles.font15_500Weight.copyWith(
                        color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
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

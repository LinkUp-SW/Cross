import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/widgets/bottom_sheet.dart';




class ProfileHeaderWidget extends ConsumerWidget {
  const ProfileHeaderWidget({super.key});

  void _handleProfilePicTap(BuildContext context) {
    final options = [
      ReusableBottomSheetOption(
        icon: Icons.camera_alt_outlined,
        title: 'Take a photo',
        onTap: () {
          // TODO: Implement take photo logic
        },
      ),
      ReusableBottomSheetOption(
        icon: Icons.arrow_upward,
        title: 'Upload from photos',
        onTap: () {
          // TODO: Implement upload photo logic
        },
      ),
       ReusableBottomSheetOption(
        icon: Icons.delete_outline, 
        title: 'Delete profile picture', 
        onTap: () {
          // TODO: Implement view logic
        },
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }

  void _handleBackgroundPicTap(BuildContext context) {
    final options = [
      ReusableBottomSheetOption(
        icon: Icons.arrow_upward,
        title: 'Upload background photo',
        onTap: () {
          // TODO: Implement upload background photo logic
        },
      ),  
       ReusableBottomSheetOption(
        icon: Icons.delete_outline, 
        title: 'Delete background photo', 
        onTap: () {
          // TODO: Implement delete background photo logic
        },
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }

  void _handleOpenToTap(BuildContext context) {
    final options = [
      ReusableBottomSheetOption(
        title: 'Finding a new job',
        subtitle: 'Show recruiters and others that you\'re open to work',
        onTap: () {
          print("Finding a new job Tapped");
          // TODO: Implement action for Finding a new job
        },
      ),
      ReusableBottomSheetOption(
        title: 'Hiring',
        subtitle: 'Share that you\'re hiring and attract qualified candidates',
        onTap: () {
          print("Hiring Tapped");
          // TODO: Implement action for Hiring
        },
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final double backgroundHeight = 70.h;

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
                onTap: () => _handleBackgroundPicTap(context), 
                child: Container(
                  height: backgroundHeight,
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
                       onPressed: () => _handleBackgroundPicTap(context), 
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, left: 16.w),
                child: GestureDetector(
                  onTap: () => _handleProfilePicTap(context), 
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
              Positioned(
                top: backgroundHeight + 5.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () {
                    GoRouter.of(context).push('/edit_intro');
                  },
                  child: CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.lightMain,
                    child: Icon(
                      Icons.edit,
                      color: AppColors.lightSecondaryText,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
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
                        onPressed: () => _handleOpenToTap(context), 
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
}
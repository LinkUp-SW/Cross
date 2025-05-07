// profile/widgets/profile_app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:go_router/go_router.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isMyProfile;

  const ProfileAppBar({
    super.key,
    required this.isMyProfile, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final appBarColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain;
    final iconColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor;
    final searchBarBackgroundColor = isDarkMode ? AppColors.darkGrey : AppColors.lightMain.withOpacity(0.8); 
    final searchBarTextColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final searchBarHintColor = isDarkMode ? AppColors.darkSecondaryText.withOpacity(0.7) : AppColors.lightGrey; 

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      automaticallyImplyLeading: false, 
      leading: IconButton( 
        icon: Icon(Icons.arrow_back, color: iconColor, size: 28.sp),
        tooltip: 'Back',
        onPressed: () {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
          
          }
        },
      ),
      title: Padding(
        padding: EdgeInsets.only(top: 0.h),
        child: Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: searchBarBackgroundColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: iconColor, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  style: TextStyles.font15_400Weight.copyWith(color: searchBarTextColor),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyles.font15_400Weight
                        .copyWith(color: searchBarHintColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isMyProfile)
          IconButton(
            icon: Icon(Icons.settings, color: iconColor, size: 28.sp),
            tooltip: 'Settings',
            onPressed: () {
              context.push('/settings');
            },
          )
        else
          SizedBox(width: 48.w), 
      ],
      centerTitle: false, 
      titleSpacing: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h); 
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart'; 
import 'package:link_up/shared/themes/text_styles.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final appBarColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain; 
    final iconColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor;
    final searchBarBackgroundColor = isDarkMode ? AppColors.darkGrey :  AppColors.lightMain;
    final searchBarTextColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor; 
    final searchBarHintColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor; 


    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(top: 13.h),
        child: Row(
          children: [


            IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor, size: 28.sp),
            
              onPressed: () => Navigator.pop(context),
            ),


            Expanded(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              icon: Icon(Icons.settings, color: iconColor, size: 28.sp), 
              onPressed: () {
                // TODO: Implement settings action
              },
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
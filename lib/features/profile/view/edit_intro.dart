import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:go_router/go_router.dart';

class EditIntroPage extends ConsumerWidget {
  const EditIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();



    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                  ),
                  Text(
                    "Edit intro",
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(width: 40.w), 
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
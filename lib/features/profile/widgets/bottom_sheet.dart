import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class ReusableBottomSheetOption {
  final IconData? icon; 
  final String title; 
  final String? subtitle; 
  final VoidCallback onTap; 

  ReusableBottomSheetOption({
    this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}


class ReusableBottomSheetContent extends StatelessWidget {
  final List<ReusableBottomSheetOption> options;

  const ReusableBottomSheetContent({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey; 
    final iconColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), 
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
             child: ListView.separated(
              shrinkWrap: true, 
              physics: const ClampingScrollPhysics(), 
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w), 
                  leading: option.icon != null
                      ? Icon(
                          option.icon,
                          color: iconColor,
                          size: 24.sp,
                        )
                      : null, 
                  title: Text(
                    option.title,
                    style: TextStyles.font16_600Weight.copyWith(
                      color: textColor,
                    ),
                  ),
                  subtitle: option.subtitle != null
                      ? Text(
                          option.subtitle!,
                          style: TextStyles.font14_400Weight.copyWith(
                            color: secondaryTextColor,
                          ),
                        )
                      : null, 
                  onTap: () {
                     Navigator.pop(context);
                     option.onTap();
                  },
                  hoverColor: AppColors.darkGrey,
                  splashColor: AppColors.lightBlue,
                );
              },
              separatorBuilder: (context, index) => Divider( 
                height: 1.h,
                thickness: 0.5,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          SizedBox(height: 8.h), 
        ],
      ),
    );
  }
}

void showReusableBottomSheet({
  required BuildContext context,
  required List<ReusableBottomSheetOption> options,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)), 
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        child: ReusableBottomSheetContent(options: options),
      );
    },
  );
}
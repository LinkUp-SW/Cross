import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

Future<bool?> showBlockConfirmationDialog(BuildContext context, String userName) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
  final secondaryTextColor = AppColors.lightGrey;
  final primaryButtonColor = Colors.red.shade700;
  final primaryButtonTextColor = Colors.white;
  final cancelButtonColor = isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.7);

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        titlePadding: EdgeInsets.zero,
        title: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 15.h, 10.w, 5.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Block $userName?',
                  textAlign: TextAlign.center,
                  style: TextStyles.font18_700Weight.copyWith(color: textColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: secondaryTextColor, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(false),
                  splashRadius: 20.r,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Cancel',
                ),
              )
            ],
          ),
        ),
        content: Text(
          'Are you sure you want to block this user? They won\'t be able to see your profile or interact with you.',
          textAlign: TextAlign.center,
          style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
        ),
        actions: <Widget>[
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               Expanded(
                 child: TextButton(
                   style: TextButton.styleFrom(
                     foregroundColor: cancelButtonColor,
                     padding: EdgeInsets.symmetric(vertical: 12.h),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8.r),
                     ),
                   ),
                   child: Text(
                     'Cancel',
                     style: TextStyles.font15_500Weight.copyWith(color: cancelButtonColor)
                   ),
                   onPressed: () => Navigator.of(context).pop(false),
                 ),
               ),
               SizedBox(width: 8.w),
               Expanded(
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: primaryButtonColor,
                     foregroundColor: primaryButtonTextColor,
                     padding: EdgeInsets.symmetric(vertical: 12.h),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8.r),
                     ),
                     minimumSize: Size.fromHeight(44.h)
                   ),
                   child: Text(
                     'Block',
                     style: TextStyles.font15_500Weight.copyWith(color: primaryButtonTextColor)
                   ),
                   onPressed: () => Navigator.of(context).pop(true),
                 ),
               ),
             ],
           )
        ],
        actionsPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
      );
    },
  );
}
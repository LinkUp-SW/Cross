import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart'; 
import 'package:go_router/go_router.dart';
class PremiumPlanSheetContent extends StatelessWidget {
  const PremiumPlanSheetContent({super.key});

  Widget _buildFeatureItem(BuildContext context, String text, {bool isUnlimited = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final checkColor = AppColors.lightGreen;
    final tagColor = AppColors.lightGreen;   
    final tagTextColor = Colors.white;        

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: checkColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyles.font14_400Weight.copyWith(color: textColor),
            ),
          ),
          if (isUnlimited) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'Unlimited',
                style: TextStyles.font10_400Weight.copyWith(color: tagTextColor),
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final buttonStyles = LinkUpButtonStyles();
    final upgradeButtonColor = isDarkMode ? AppColors.darkBlue : AppColors.lightBlue;
    final upgradeButtonTextColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain;

    return Container(
       padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h + MediaQuery.of(context).viewPadding.bottom),
       child: Stack(
         children: [
           Column(
             mainAxisSize: MainAxisSize.min, 
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                SizedBox(height: 30.h), 
               Text(
                 'Premium Plan',
                 style: TextStyles.font20_700Weight.copyWith(color: textColor),
               ),
               SizedBox(height: 4.h),
               Text(
                 'Unlock all features and grow your network',
                 style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
               ),
               SizedBox(height: 15.h),
               Text.rich(
                 TextSpan(
                   children: [
                     TextSpan(
                       text: '\$9.99', 
                       style: TextStyles.font30_600Weight.copyWith(color: textColor),
                     ),
                     TextSpan(
                       text: ' /month',
                       style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ]
                 )
               ),
               SizedBox(height: 20.h),
               _buildFeatureItem(context, 'Create a profile with basic information'),
               _buildFeatureItem(context, 'Connect with 500+ people', isUnlimited: true),
               _buildFeatureItem(context, 'Unlimited job applications', isUnlimited: true),
               _buildFeatureItem(context, 'Unlimited messaging', isUnlimited: true),
               _buildFeatureItem(context, 'Priority customer support'),
               SizedBox(height: 25.h), 
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                    GoRouter.of(context).push('/payment');
                     Navigator.pop(context); 
                     print("Upgrade Now button pressed!");
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription flow not implemented yet.'))
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: upgradeButtonColor,
                     foregroundColor: upgradeButtonTextColor,
                     padding: EdgeInsets.symmetric(vertical: 12.h),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8.r),
                     ),
                   ).merge(isDarkMode ? buttonStyles.wideBlueElevatedButtonDark() : buttonStyles.wideBlueElevatedButton()),
                   child: Text(
                     "Upgrade Now",
                     style: TextStyles.font15_500Weight.copyWith(color: upgradeButtonTextColor),
                   ),
                 ),
               ),
             ],
           ),
           Positioned(
             top: 0,
             right: 0,
             child: IconButton(
               icon: Icon(Icons.close, color: secondaryTextColor, size: 24.sp),
               padding: EdgeInsets.zero,
               constraints: const BoxConstraints(),
               splashRadius: 20.r,
               onPressed: () => Navigator.pop(context),
               tooltip: 'Close',
             ),
           ),
         ],
       ),
    );
  }
}


void showPremiumPlanSheet(BuildContext context) {
   final isDarkMode = Theme.of(context).brightness == Brightness.dark;

   showModalBottomSheet(
     context: context,
     isScrollControlled: true, 
     backgroundColor: isDarkMode ? const Color(0xFF1E2A3B) : AppColors.lightMain,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)), 
     ),
     builder: (BuildContext context) {
       return const PremiumPlanSheetContent();
     },
   );
}
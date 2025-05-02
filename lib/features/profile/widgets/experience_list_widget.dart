import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';

class ExperienceListItem extends StatelessWidget {
  final PositionModel exp;
  final bool isDarkMode;

  const ExperienceListItem({
    super.key,
    required this.exp,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final logoUrl = exp.companyLogoUrl;
    final DateTime? startDate = DateTime.tryParse(exp.startDate);
    final DateTime? endDate = !exp.isCurrent && exp.endDate != null ? DateTime.tryParse(exp.endDate!) : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
             color: isDarkMode ? AppColors.darkGrey.withOpacity(0.1) : AppColors.lightGrey.withOpacity(0.1),
             borderRadius: BorderRadius.circular(4.r),
          ),
          child: ClipRRect(
             borderRadius: BorderRadius.circular(4.r),
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp),
                     errorWidget: (context, url, error) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp),
                     fit: BoxFit.contain,
                   )
                 : Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exp.title, style: TextStyles.font16_600Weight.copyWith(color: textColor)),
              SizedBox(height: 2.h),
              Text('${exp.companyName}${exp.employeeType.isNotEmpty ? ' · ${exp.employeeType}' : ''}', style: TextStyles.font14_400Weight.copyWith(color: textColor)),
              SizedBox(height: 2.h),
              Text(formatDateRange(startDate, endDate, isCurrent: exp.isCurrent), style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
              if ((exp.location != null && exp.location!.isNotEmpty) || (exp.locationType != null && exp.locationType!.isNotEmpty))
                 Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text('${exp.location ?? ""}${exp.location != null && exp.locationType != null ? ' · ' : ''}${exp.locationType ?? ""}', style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
                 ),
              if (exp.skills != null && exp.skills!.isNotEmpty)
                buildSkillsRowWidget(exp.skills!, isDarkMode),
            ],
          ),
        ),
         IconButton(
           icon: Icon(Icons.edit, color: secondaryTextColor, size: 20.sp),
           splashRadius: 20.r,
           constraints: const BoxConstraints(),
           padding: EdgeInsets.zero,
           tooltip: "Edit Experience",
           onPressed: () {
             // TODO: Navigate to edit specific experience page
             // Example: GoRouter.of(context).push('/edit_position/${experience.id}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit specific item not implemented yet.'))
             );
           },
        ),
      ],
    );
  }
}
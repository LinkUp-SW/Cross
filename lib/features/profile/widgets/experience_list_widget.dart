import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ExperienceListItem extends ConsumerWidget {
  final PositionModel exp;
  final bool isDarkMode;
  final bool showActions;

  const ExperienceListItem({
    super.key,
    required this.exp,
    required this.isDarkMode,
    this.showActions = true,
  });
Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Experience?'),
        content: const Text('Are you sure you want to delete this experience record? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false), 
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true), 
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context, WidgetRef ref) { 
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
        if (showActions)
        Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: secondaryTextColor, size: 20.sp),
                  splashRadius: 20.r,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: "Edit Experience",
                  
                  onPressed: () {
                    if (exp.id != null) {
                      GoRouter.of(context).push('/add_new_position', extra: exp);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot edit: Item ID is missing.'), backgroundColor: Colors.orange)
                      );
                    }
                  },
                ),
                SizedBox(width: 4.w), 
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20.sp),
                  splashRadius: 20.r,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: "Delete Experience",
                  onPressed: () async {
                    if (exp.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot delete: Item ID is missing.'), backgroundColor: Colors.orange));
                      return;
                    }
                    final confirm = await _showDeleteConfirmationDialog(context);
                    if (confirm == true && context.mounted) {
                      try {
                        final profileService = ref.read(profileServiceProvider);
                        final success = await profileService.deleteExperience(exp.id!);

                        if (success && context.mounted) { 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Experience deleted.'), backgroundColor: Colors.green));
                        unawaited(ref.read(profileViewModelProvider.notifier).fetchUserProfile());
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete experience.'), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        if (context.mounted) { 
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting experience: ${e.toString()}'), backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                ),
              ],
            )
          ],
        );
      }
    }
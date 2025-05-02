import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'dart:developer';


class SkillListItem extends ConsumerWidget { 
  final SkillModel skill;
  final bool isDarkMode;

  const SkillListItem({
    super.key,
    required this.skill,
    required this.isDarkMode,
  });

  Widget _buildLinkedItemRow({
      required BuildContext context,
      required String name,
      String? logoUrl,
      required IconData fallbackIcon,
      required Color iconColor}) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: logoUrl != null && logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: logoUrl,
                      placeholder: (context, url) => Icon(fallbackIcon, color: iconColor, size: 18.sp),
                      errorWidget: (context, url, error) => Icon(fallbackIcon, color: iconColor, size: 18.sp),
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(fallbackIcon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              style: TextStyles.font12_400Weight.copyWith(color: AppColors.lightGrey), 
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final iconColor = isDarkMode ? AppColors.darkGrey : AppColors.lightGrey;

    final allEducations = ref.watch(educationDataProvider);
    final allExperiences = ref.watch(experienceDataProvider);
    final allLicenses = ref.watch(licenseDataProvider);


    Map<String, String?> getLinkedItemDetails(String id, String type) {
      log('[getLinkedItemDetails] Looking for ID: "$id", Type: "$type"');
      try {
        switch (type) {
          case 'education':
            final foundEdu = allEducations?.firstWhere((e) => e.id == id); 
            if (foundEdu != null) {
              return {'name': foundEdu.institution, 'logo': foundEdu.logoUrl};
            }
            break; 
          case 'license':
             final foundLic = allLicenses?.firstWhere((l) => l.id == id); 
             if (foundLic != null) {
               return {'name': foundLic.issuingOrganizationName, 'logo': foundLic.issuingOrganizationLogoUrl};
             }
            break; 

        }
      } catch (e) {
         log('[getLinkedItemDetails] Error during lookup for ID "$id", Type "$type": $e');
      }
       log('[$type ID "$id" NOT FOUND or error occurred]');
       return {'name': 'Linked item not found', 'logo': null}; 
    }

    List<Widget> linkedItemsWidgets = [];

    if (skill.educations != null && skill.educations!.isNotEmpty) {
      linkedItemsWidgets.addAll(skill.educations!.map((id) {
        final details = getLinkedItemDetails(id, 'education');
        return _buildLinkedItemRow(context: context, name: details['name'] ?? 'Error', logoUrl: details['logo'], fallbackIcon: Icons.school_outlined, iconColor: iconColor);
      }));
    }

    if (skill.licenses != null && skill.licenses!.isNotEmpty) {
      linkedItemsWidgets.addAll(skill.licenses!.map((id) {
        final details = getLinkedItemDetails(id, 'license');
        return _buildLinkedItemRow(context: context, name: details['name'] ?? 'Error', logoUrl: details['logo'], fallbackIcon: Icons.card_membership_outlined, iconColor: iconColor);
      }));
    }

    final linkedExperiences = allExperiences?.where((exp) => exp.skills?.contains(skill.name) ?? false).toList();
    if (linkedExperiences != null && linkedExperiences.isNotEmpty) {
      linkedItemsWidgets.addAll(linkedExperiences.map((exp) {
        return _buildLinkedItemRow(
          context: context,
          name: '${exp.title} at ${exp.companyName}',
          logoUrl: exp.companyLogoUrl,
          fallbackIcon: Icons.business_center_outlined,
          iconColor: iconColor
        );
      }));
    }

     return Row( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: TextStyles.font16_600Weight.copyWith(color: textColor),
                ),
                if (linkedItemsWidgets.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, bottom: 4.h), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: linkedItemsWidgets,
                    ),
                  ),
              ],
            ),
          ),
           IconButton(
             icon: Icon(Icons.edit, color: secondaryTextColor, size: 20.sp),
             splashRadius: 20.r,
             constraints: const BoxConstraints(),
             padding: EdgeInsets.zero,
             tooltip: "Edit Skill",
             onPressed: () {
               // TODO: Navigate to edit specific skill page (might need ID)
               // Example: GoRouter.of(context).push('/edit_skill/${skill.id}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit specific item not implemented yet.'))
               );
             },
          ),
        ],
     );
  }
}
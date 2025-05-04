import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:developer';
import 'package:go_router/go_router.dart';


class SkillListItem extends ConsumerWidget { 
  final SkillModel skill;
  final bool isDarkMode;
    final bool showActions;


  const SkillListItem({
    super.key,
    required this.skill,
    required this.isDarkMode,
    this.showActions = true,
  });
Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Skill?'),
        content: const Text('Are you sure you want to delete this Skill record? This action cannot be undone.'),
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
          if (showActions)
           Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: secondaryTextColor, size: 20.sp),
              splashRadius: 20.r,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              tooltip: "Edit Skill",
                  onPressed: () {
                    if (skill.id != null) {
                      GoRouter.of(context).push('/add_new_skill', extra: skill);
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
              tooltip: "Delete Skill",
              onPressed: () async {
                if (skill.id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot delete: Item ID is missing.'), backgroundColor: Colors.orange));
                  return;
                }
                final confirm = await _showDeleteConfirmationDialog(context);
                if (confirm == true && context.mounted) {
                  try {
                    final profileService = ref.read(profileServiceProvider);
                    final success = await profileService.deleteSkill(skill.id!);

                  if (success && context.mounted) { 
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Skill deleted.'), backgroundColor: Colors.green));
                        unawaited(ref.read(profileViewModelProvider.notifier).fetchUserProfile());
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete Skill.'), backgroundColor: Colors.red));
                        }
                  } catch (e) {
                     if (context.mounted) { 
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting Skill: ${e.toString()}'), backgroundColor: Colors.red));
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
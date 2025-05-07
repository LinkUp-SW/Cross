import 'package:flutter/material.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';


class LicenseListItem extends ConsumerWidget {
  final LicenseModel license;
  final bool isDarkMode;
  final bool showActions; 

  const LicenseListItem({
    super.key,
    required this.license,
    required this.isDarkMode,
    this.showActions = true,

  });

Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete License?'),
        content: const Text('Are you sure you want to delete this License record? This action cannot be undone.'),
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
  Widget build(BuildContext context, ref) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final logoUrl = license.issuingOrganizationLogoUrl;
    final DateTime? issueDate = license.issueDate;
    final DateTime? expirationDate = license.expirationDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    placeholder: (context, url) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp),
                    errorWidget: (context, url, error) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp),
                    fit: BoxFit.contain,
                  )
                : Center(child: Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(license.name, style: TextStyles.font16_600Weight.copyWith(color: textColor)),
              SizedBox(height: 2.h),
              Text(license.issuingOrganizationName, style: TextStyles.font14_400Weight.copyWith(color: textColor)),
              SizedBox(height: 2.h),
              Text(
                formatDateRange(
                  issueDate,
                  expirationDate,
                  isCurrent: false,
                  doesNotExist: license.doesNotExpire,
                ),
                style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
              ),
              if (license.credentialId != null && license.credentialId!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Credential ID: ${license.credentialId}',
                    style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                  ),
                ),
              if (license.credentialUrl != null && license.credentialUrl!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: InkWell(
                    onTap: () => launchUrlHelper(context, license.credentialUrl),
                    child: Text(
                      'Show credential',
                      style: TextStyles.font12_400Weight.copyWith(
                        color: AppColors.lightBlue,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.lightBlue,
                      ),
                    ),
                  ),
                ),
              if (license.skills != null && license.skills!.isNotEmpty)
                buildSkillsRowWidget(license.skills!, isDarkMode),
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
                  tooltip: "Edit license",
                  onPressed: () {
                    if (license.id != null) {
                      GoRouter.of(context).push('/add_new_license', extra: license);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot edit: Item ID is missing.'), backgroundColor: Colors.orange)
                      );
                    }                  },
                ),
                SizedBox(width: 4.w), 
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20.sp),
                  splashRadius: 20.r,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: "Delete license",
                  onPressed: () async {
                    if (license.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot delete: Item ID is missing.'), backgroundColor: Colors.orange));
                      return;
                    }
                    final confirm = await _showDeleteConfirmationDialog(context);
                    if (confirm == true && context.mounted) {
                      try {
                        final profileService = ref.read(profileServiceProvider);
                        final success = await profileService.deleteLicense(license.id!);

                        if (success && context.mounted) { 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('license deleted.'), backgroundColor: Colors.green));
                        unawaited(ref.read(profileViewModelProvider.notifier).fetchUserProfile());
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete license.'), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        if (context.mounted) { 
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting license: ${e.toString()}'), backgroundColor: Colors.red));
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
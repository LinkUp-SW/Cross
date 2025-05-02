import 'package:flutter/material.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';

class LicenseListItem extends StatelessWidget {
  final LicenseModel license;
  final bool isDarkMode;

  const LicenseListItem({
    super.key,
    required this.license,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
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
        IconButton(
          icon: Icon(Icons.edit, color: secondaryTextColor, size: 20.sp),
          splashRadius: 20.r,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          tooltip: "Edit License/Certification",
          onPressed: () {
            // TODO: Navigate to edit specific license page
            // Example: GoRouter.of(context).push('/edit_license/${license.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit specific item not implemented yet.')),
            );
          },
        ),
      ],
    );
  }
}
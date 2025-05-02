// profile/view/view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/license_model.dart';
import 'package:link_up/features/profile/model/about_model.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/profile_app_bar_widget.dart';
import 'package:link_up/features/profile/widgets/profile_header_widget.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/features/profile/widgets/empty_section_placeholder.dart'; 
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).fetchUserProfile();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    try {
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      log("Error formatting date '$date': $e");
      return date.toIso8601String().split('T').first;
    }
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate, {bool isCurrent = false, bool doesNotExist = false}) {
    final startFormatted = _formatDate(startDate);

    if (startFormatted.isEmpty) return 'Date missing';

    if (isCurrent || (endDate == null && !doesNotExist)) {
      return '$startFormatted - Present';
    } else if (doesNotExist) {
      return '$startFormatted - No Expiration';
    } else {
      final endFormatted = _formatDate(endDate);
      if (endFormatted.isNotEmpty) {
         return '$startFormatted - $endFormatted';
      } else {
         return startFormatted;
      }
    }
  }

  Widget _buildSkillsRowWidget(List<String> skills, bool isDarkMode) {
     if (skills.isEmpty) {
       return const SizedBox.shrink();
     }
     final displayedSkills = skills.take(2).toList();
     String skillsText = displayedSkills.join(' • ');
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;

     return Padding(
       padding: EdgeInsets.only(top: 6.h),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Icon(Icons.star_outline, size: 14.sp, color: secondaryTextColor),
           SizedBox(width: 6.w),
           Expanded(
             child: Text(
               skillsText,
               style: TextStyles.font13_500Weight.copyWith(color: textColor),
             ),
           ),
         ],
       ),
     );
  }

  Future<void> _launchUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('No URL provided.'), backgroundColor: Colors.orange)
       );
       return;
    }

    String urlToLaunch = urlString.trim();
     if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
       urlToLaunch = 'https://$urlToLaunch';
     }


    final Uri? url = Uri.tryParse(urlToLaunch);
    if (url == null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $urlString'), backgroundColor: Colors.red));
      return;
    }

    if (await canLaunchUrl(url)) {
      try {
         await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch(e) {
         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch URL: $e'), backgroundColor: Colors.red));
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url'), backgroundColor: Colors.orange));
    }
  }
 Widget _buildSkillItem(SkillModel skill, bool isDarkMode, List<EducationModel>? educations, List<PositionModel>? experiences, List<LicenseModel>? licenses) {
  final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
  final secondaryTextColor = AppColors.lightGrey;
  final iconColor = isDarkMode ? AppColors.darkGrey : AppColors.lightGrey;

  log('[BuildSkillItem:${skill.name}] Received Educations: ${educations?.length ?? 'null'}, Experiences: ${experiences?.length ?? 'null'}, Licenses: ${licenses?.length ?? 'null'}');

  Map<String, String?> getLinkedItemDetails(String id, String type) {
    log('[getLinkedItemDetails] Looking for ID: "$id", Type: "$type"');
    try {
      switch (type) {
        case 'education':
          final foundEdu = educations?.firstWhere((e) => e.id == id);
          if (foundEdu != null) {
            log('[getLinkedItemDetails] Found Education: ${foundEdu.institution}, Logo: ${foundEdu.logoUrl}');
            return {'name': foundEdu.institution, 'logo': foundEdu.logoUrl};
          } else {
            log('[getLinkedItemDetails] Education ID "$id" NOT FOUND in list.');
            return {'name': 'Item not found', 'logo': null};
          }
        case 'license':
          final foundLic = licenses?.firstWhere((l) => l.id == id);
          if (foundLic != null) {
            log('[getLinkedItemDetails] Found License: ${foundLic.issuingOrganizationName}, Logo: ${foundLic.issuingOrganizationLogoUrl}');
            return {'name': foundLic.issuingOrganizationName, 'logo': foundLic.issuingOrganizationLogoUrl};
          } else {
            log('[getLinkedItemDetails] License ID "$id" NOT FOUND in list.');
            return {'name': 'Item not found', 'logo': null};
          }
        default:
          log('[getLinkedItemDetails] Unknown type "$type" for ID "$id".');
          return {'name': 'Unknown Item Type', 'logo': null};
      }
    } catch (e) {
      log('[getLinkedItemDetails] Error during lookup for ID "$id", Type "$type": $e');
      return {'name': 'Item not found', 'logo': null};
    }
  }

  List<Widget> linkedItemsWidgets = [];

  Widget buildLinkedItemRow({required String name, String? logoUrl, required IconData fallbackIcon}) {
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
              style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  if (skill.educations != null && skill.educations!.isNotEmpty) {
    log('[BuildSkillItem:${skill.name}] Processing ${skill.educations!.length} linked Education IDs: ${skill.educations}');
    linkedItemsWidgets.addAll(skill.educations!.map((id) {
      final details = getLinkedItemDetails(id, 'education');
      return buildLinkedItemRow(name: details['name'] ?? 'Error', logoUrl: details['logo'], fallbackIcon: Icons.school_outlined);
    }));
  }

  if (skill.licenses != null && skill.licenses!.isNotEmpty) {
    log('[BuildSkillItem:${skill.name}] Processing ${skill.licenses!.length} linked License IDs: ${skill.licenses}');
    linkedItemsWidgets.addAll(skill.licenses!.map((id) {
      final details = getLinkedItemDetails(id, 'license');
      return buildLinkedItemRow(name: details['name'] ?? 'Error', logoUrl: details['logo'], fallbackIcon: Icons.card_membership_outlined);
    }));
  }

  final linkedExperiences = experiences?.where((exp) => exp.skills?.contains(skill.name) ?? false).toList();
  if (linkedExperiences != null && linkedExperiences.isNotEmpty) {
    log('[BuildSkillItem:${skill.name}] Found ${linkedExperiences.length} matching Experiences');
    linkedItemsWidgets.addAll(linkedExperiences.map((exp) {
      return buildLinkedItemRow(
        name: '${exp.title} at ${exp.companyName}',
        logoUrl: exp.companyLogoUrl,
        fallbackIcon: Icons.business_center_outlined,
      );
    }));
  } else {
    log('[BuildSkillItem:${skill.name}] No matching experiences found.');
  }

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          skill.name,
          style: TextStyles.font14_600Weight.copyWith(color: textColor),
        ),
        if (linkedItemsWidgets.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: linkedItemsWidgets,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildEducationItem(EducationModel edu, bool isDarkMode) {
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;
     final logoUrl = edu.logoUrl;

     final DateTime? startDate = DateTime.tryParse(edu.startDate);
     final DateTime? endDate = edu.endDate != null ? DateTime.tryParse(edu.endDate!) : null;
     final bool isCurrentlyStudying = edu.endDate == null || edu.endDate!.isEmpty;


     return Padding(
       padding: EdgeInsets.symmetric(vertical: 8.h),
       child: Row(
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
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp),
                     errorWidget: (context, url, error) => Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp),
                     fit: BoxFit.contain,
                   )
                 : Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
           ),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   edu.institution,
                   style: TextStyles.font18_600Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2.h),
                 if (edu.degree.isNotEmpty || edu.fieldOfStudy.isNotEmpty)
                   Text(
                     '${edu.degree}${edu.degree.isNotEmpty && edu.fieldOfStudy.isNotEmpty ? ', ' : ''}${edu.fieldOfStudy}',
                     style: TextStyles.font14_400Weight.copyWith(color: textColor),
                   ),
                 SizedBox(height: 2.h),
                 Text(
                  _formatDateRange(startDate, endDate, isCurrent: isCurrentlyStudying, doesNotExist: false),
                   style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                 ),
                 SizedBox(height: 4.h),
                 if (edu.grade != null && edu.grade!.isNotEmpty)
                   Text(
                     'Grade: ${edu.grade}',
                     style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                   ),
                 if (edu.activitesAndSocials != null && edu.activitesAndSocials!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: edu.grade != null && edu.grade!.isNotEmpty ? 4.h : 0),
                     child: Text(
                       'Activities and societies: ${edu.activitesAndSocials}',
                       style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ),
                 if (edu.description != null && edu.description!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4.h),
                     child: Text(
                       edu.description!,
                       style: TextStyles.font13_400Weight.copyWith(color: textColor),
                     ),
                   ),
                 if (edu.skills != null && edu.skills!.isNotEmpty)
                   _buildSkillsRowWidget(edu.skills!, isDarkMode),
               ],
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildExperienceItem(PositionModel exp, bool isDarkMode) {
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;
     final logoUrl = exp.companyLogoUrl;

     final DateTime? startDate = DateTime.tryParse(exp.startDate);
     final DateTime? endDate = !exp.isCurrent && exp.endDate != null ? DateTime.tryParse(exp.endDate!) : null;


     return Padding(
       padding: EdgeInsets.symmetric(vertical: 8.h),
       child: Row(
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
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp),
                     errorWidget: (context, url, error) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp),
                     fit: BoxFit.contain,
                   )
                 : Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)),
           ),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   exp.title,
                   style: TextStyles.font18_600Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2.h),
                 Text(
                   '${exp.companyName}${exp.employeeType.isNotEmpty ? ' · ${exp.employeeType}' : ''}',
                   style: TextStyles.font14_400Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2.h),
                 Text(
                   _formatDateRange(startDate, endDate, isCurrent: exp.isCurrent, doesNotExist: false),
                   style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                 ),
                 if (exp.location != null && exp.location!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4.h),
                     child: Text(
                       exp.location!,
                       style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ),
                 if (exp.description != null && exp.description!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4.h),
                     child: Text(
                       exp.description!,
                       style: TextStyles.font13_400Weight.copyWith(color: textColor),
                     ),
                   ),
                 if (exp.skills != null && exp.skills!.isNotEmpty)
                   _buildSkillsRowWidget(exp.skills!, isDarkMode),
               ],
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildLicenseItem(LicenseModel lic, bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final logoUrl = lic.issuingOrganizationLogoUrl;

    final DateTime? issueDate = lic.issueDate;
    final DateTime? expirationDate = lic.expirationDate;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
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
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    placeholder: (context, url) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp),
                    errorWidget: (context, url, error) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp),
                    fit: BoxFit.contain,
                  )
                : Center(child: Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20.sp)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lic.name,
                  style: TextStyles.font18_600Weight.copyWith(color: textColor),
                ),
                SizedBox(height: 2.h),
                Text(
                  lic.issuingOrganizationName,
                  style: TextStyles.font14_400Weight.copyWith(color: textColor),
                ),
                SizedBox(height: 2.h),
                 Text(
                   _formatDateRange(
                       issueDate,
                       expirationDate,
                       isCurrent: false,
                       doesNotExist: lic.doesNotExpire
                    ),
                   style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                 ),
                if (lic.credentialId != null && lic.credentialId!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'Credential ID: ${lic.credentialId}',
                      style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                    ),
                  ),
                 if (lic.credentialUrl != null && lic.credentialUrl!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4.h),
                     child: InkWell(
                       onTap: () => _launchUrl(context, lic.credentialUrl),
                       child: Text(
                         'Show credential',
                         style: TextStyles.font12_400Weight.copyWith(
                           color: AppColors.lightBlue,
                           decoration: TextDecoration.underline,
                         ),
                       ),
                     ),
                   ),
                if (lic.skills != null && lic.skills!.isNotEmpty)
                  _buildSkillsRowWidget(lic.skills!, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
     final profileState = ref.watch(profileViewModelProvider);
     final allEducations = ref.watch(educationDataProvider);
     final allExperiences = ref.watch(experienceDataProvider);
     final allLicenses = ref.watch(licenseDataProvider);
     final aboutData = ref.watch(aboutDataProvider);
     final resumeUrl = ref.watch(resumeUrlProvider);
     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final allSkills = ref.watch(skillsDataProvider); 

     final displayedSkills = allSkills?.take(2).toList() ?? []; 
     final totalSkillCount = allSkills?.length ?? 0;
     final showShowAllSkillsButton = totalSkillCount > 2;
     final displayedEducations = allEducations?.take(2).toList() ?? [];
     final displayedExperiences = allExperiences?.take(2).toList() ?? [];
     final displayedLicenses = allLicenses?.take(2).toList() ?? [];
     final totalEducationCount = allEducations?.length ?? 0;
     final totalExperienceCount = allExperiences?.length ?? 0;
     final totalLicenseCount = allLicenses?.length ?? 0;
     final showShowAllEducationButton = totalEducationCount > 2;
     final showShowAllExperienceButton = totalExperienceCount > 2;
     final showShowAllLicensesButton = totalLicenseCount > 2;
     final bool hasAboutText = aboutData?.about.isNotEmpty ?? false;
     final bool hasAboutSkills = aboutData?.skills.isNotEmpty ?? false;
     final bool showAboutSection = hasAboutText || hasAboutSkills;
     final bool hasResume = resumeUrl != null && resumeUrl.isNotEmpty;

     final buttonStyles = LinkUpButtonStyles();
     final addButtonStyle = isDarkMode
         ? buttonStyles.blueOutlinedButtonDark()
         : buttonStyles.blueOutlinedButton();
     final addTextColor = isDarkMode ? AppColors.darkBlue : AppColors.lightBlue;
     final sectionTextColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const ProfileAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(profileViewModelProvider.notifier).fetchUserProfile(),
        child: switch (profileState) {
          ProfileLoading() => const Center(child: CircularProgressIndicator()),
          ProfileError(:final message) => Center(
               child: Padding(
                 padding: EdgeInsets.all(16.w),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text('Error: $message', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
                     SizedBox(height: 10.h),
                     ElevatedButton(
                       onPressed: () => ref.read(profileViewModelProvider.notifier).fetchUserProfile(),
                       child: const Text('Retry'),
                     )
                   ],
                 ),
               ),
            ),
          ProfileLoaded(:final userProfile) => SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeaderWidget(userProfile: userProfile),

                  if (hasResume)
                   SectionWidget(
                     title: "Resume",
                     onEditPressed: () => GoRouter.of(context).push('/add_resume'),
                     child: profileState is ProfileLoading
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(
                                 height: 300,
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(8.r),
                                   border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                                 ),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(8.r),
                                   child: PDF().cachedFromUrl(
                                     resumeUrl!,
                                     placeholder: (progress) => Center(child: Text('Loading: $progress %')),
                                     errorWidget: (error) => Center(child: Text('Error loading PDF: ${error.toString()}')),
                                   ),
                                 ),
                               ),
                               SizedBox(height: 8.h),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: TextButton.icon(
                                   onPressed: () => GoRouter.of(context).push('/resume_viewer', extra: resumeUrl),
                                   icon: Icon(Icons.open_in_full, size: 16.sp),
                                   label: Text('Open Fullscreen', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)),
                                 ),
                               ),
                             ],
                           ),
                   ),

                    if (showAboutSection)
                      SectionWidget(
                        title: "About",
                        onEditPressed: () => GoRouter.of(context).push('/edit_about'),
                        child: aboutData == null
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               if (hasAboutText)
                                 Padding(
                                   padding: EdgeInsets.only(bottom: hasAboutSkills ? 0 : 8.h),
                                   child: Text(aboutData.about, style: TextStyles.font14_400Weight.copyWith(color: sectionTextColor)),
                                 ),
                               if (hasAboutSkills)
                                 _buildSkillsRowWidget(aboutData.skills, isDarkMode),
                             ],
                           )
                      ),

                      SectionWidget(
                            title: "Experience",
                            onAddPressed: () => GoRouter.of(context).push('/add_new_position'), 
                            onEditPressed: allExperiences != null && allExperiences.isNotEmpty
                                ? () => GoRouter.of(context).push('/edit_experience_list')
                                : null, 
                            child: allExperiences == null
                                ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) 
                                : (allExperiences.isEmpty) 
                                  ? EmptySectionPlaceholder(
                                      icon: Icons.business_center_outlined,
                                      titlePlaceholder: "Job Title",
                                      subtitlePlaceholder: "Organization",
                                      datePlaceholder: "YYYY - Present", 
                                      sectionSubtitle: "Showcase your accomplishments and get up to 2X as many profile views and connections", 
                                      callToActionText: "Add Experience",
                                      onAddPressed: () => GoRouter.of(context).push('/add_new_position'),
                                    )
                       : Column(
                           children: [
                             Column(children: displayedExperiences.map((exp) => _buildExperienceItem(exp, isDarkMode)).toList()),
                               if (showShowAllExperienceButton) ...[
                                 Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3))),
                                 SizedBox(
                                   width: double.infinity,
                                   child: TextButton(
                                     onPressed: () { /* TODO: Show All Experience */ },
                                     style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalExperienceCount experiences', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                   ),
                                 ),
                               ]
                             ],
                           ),
                   ),

               SectionWidget(
                 title: "Education",
                 onAddPressed: () => GoRouter.of(context).push('/add_new_education'), 
                  onEditPressed: allEducations != null && allEducations.isNotEmpty
                     ? () => GoRouter.of(context).push('/edit_education_list')
                     : null, 
                 child: allEducations == null
                     ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) 
                     : (allEducations.isEmpty) 
                       
                       ? EmptySectionPlaceholder(
                           icon: Icons.business_center_outlined,
                           titlePlaceholder: "Degree",
                           subtitlePlaceholder: "School Name",
                           datePlaceholder: "YYYY - Present", 
                           sectionSubtitle: "Add your education details to show case your academic background", 
                           callToActionText: "Add Education",
                           onAddPressed: () => GoRouter.of(context).push('/add_new_education'),
                         )
                       : Column(
                           children: [
                                  Column(children: displayedEducations.map((edu) => _buildEducationItem(edu, isDarkMode)).toList()),
                                if (showShowAllEducationButton) ...[
                                  Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3))),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () { /* TODO: Show All Education */ },
                                      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalEducationCount educations', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                    ),
                                  ),
                                ]
                             ],
                           ),
                    ),


                   SectionWidget(
                     title: "Licenses & Certifications",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_license'),
                     onEditPressed: allLicenses != null && allLicenses.isNotEmpty
                         ? () => GoRouter.of(context).push('/edit_licenses_list') // TODO: Implement Licenses list editing page
                         : null,
                     child: allLicenses == null 
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : allLicenses.isEmpty
                           ? EmptySectionPlaceholder(
                               icon: Icons.card_membership_outlined, 
                               titlePlaceholder: "License/Certification Name",
                               subtitlePlaceholder: "Issuing Organization",
                               datePlaceholder: "YYYY-Present", 
                               sectionSubtitle: "Add your licenses details to show case your academic background", 
                               callToActionText: "Add License", 
                               onAddPressed: () => GoRouter.of(context).push('/add_new_license'), 
                             )
                           : Column(
                               children: [
                                 Column(
                                   children: displayedLicenses
                                       .map((lic) => _buildLicenseItem(lic, isDarkMode))
                                       .toList(),
                                 ),
                                 if (showShowAllLicensesButton) ...[
                                   Padding(
                                     padding: EdgeInsets.only(top: 8.h),
                                     child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3)) // Adjusted divider color for consistency
                                   ),
                                   SizedBox(
                                     width: double.infinity,
                                     child: TextButton(
                                       onPressed: () { /* TODO: Implement Show All Licenses */ },
                                       style: TextButton.styleFrom(
                                           padding: EdgeInsets.symmetric(vertical: 8.h),
                                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                           alignment: Alignment.center
                                        ),
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Text(
                                             'Show all $totalLicenseCount licenses', 
                                             style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)
                                           ),
                                           SizedBox(width: 4.w),
                                           Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)
                                         ]
                                       ),
                                     ),
                                   ),
                                 ]
                               ],
                             ),
                   ),

                   SectionWidget(
                     title: "Skills",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_skill'), 
                     onEditPressed: allSkills != null && allSkills.isNotEmpty
                         ? () { /* TODO: Navigate to skills reorder/edit page */ }
                         : null, 
                     child: allSkills == null 
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : allSkills.isEmpty
                           ? EmptySectionPlaceholder(
                               icon: Icons.star_outline, 
                               titlePlaceholder: "Skill Name", 
                               subtitlePlaceholder: "e.g., Project Management", 
                               datePlaceholder: "", 
                               callToActionText: "Add Skill", 
                               onAddPressed: () => GoRouter.of(context).push('/add_new_skill'), 
                             )
                           : Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: displayedSkills.asMap().entries.map((entry) {
                                     int index = entry.key;
                                     SkillModel skill = entry.value;
                                     bool isLastItem = index == displayedSkills.length - 1;

                                     return Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         _buildSkillItem(
                                           skill,
                                           isDarkMode,
                                           allEducations,
                                           allExperiences,
                                           allLicenses,
                                         ),
                                         if (!isLastItem)
                                           Padding(
                                             padding: EdgeInsets.symmetric(vertical: 8.h),
                                             child: Divider(
                                               height: 1.h,
                                               thickness: 0.5,
                                               color: isDarkMode
                                                   ? AppColors.darkGrey.withOpacity(0.5)
                                                   : AppColors.lightGrey.withOpacity(0.3),
                                             ),
                                           ),
                                       ],
                                     );
                                   }).toList(),
                                 ),
                                 if (showShowAllSkillsButton) ...[
                                   Padding(
                                     padding: EdgeInsets.only(top: 8.h),
                                     child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3))
                                   ),
                                   SizedBox(
                                     width: double.infinity,
                                     child: TextButton(
                                       onPressed: () { /* TODO: Implement Show All Skills */ },
                                       style: TextButton.styleFrom(
                                           padding: EdgeInsets.symmetric(vertical: 8.h),
                                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                           alignment: Alignment.center
                                        ),
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Text(
                                             'Show all $totalSkillCount skills',
                                             style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)
                                           ),
                                           SizedBox(width: 4.w),
                                           Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)
                                         ]
                                       ),
                                     ),
                                   ),
                                 ]
                               ],
                             ),
                   ),
                   // --- End of Skills Section ---
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ProfileInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
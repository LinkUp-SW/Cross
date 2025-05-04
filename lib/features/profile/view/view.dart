
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
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';
import 'package:link_up/features/profile/widgets/experience_list_widget.dart';
import 'package:link_up/features/profile/widgets/education_list_widget.dart';
import 'package:link_up/features/profile/widgets/license_list_widget.dart';
import 'package:link_up/features/profile/widgets/skills_list_widget.dart';
import 'package:link_up/features/profile/widgets/empty_section_placeholder.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';
import 'package:link_up/features/profile/widgets/profile_activity_preview.dart';
import 'package:link_up/features/profile/model/profile_model.dart'; 

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).fetchUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
     final profileState = ref.watch(profileViewModelProvider);
     final allEducations = ref.watch(educationDataProvider);
     final allExperiences = ref.watch(experienceDataProvider);
     final allLicenses = ref.watch(licenseDataProvider);
     final aboutData = ref.watch(aboutDataProvider);
     final resumeUrl = ref.watch(resumeUrlProvider);
     final allSkills = ref.watch(skillsDataProvider);

     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
     final sectionTextColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;

     bool isMyProfile = false;
     UserProfile? currentUserProfile; 

     if (profileState is ProfileLoaded) {
       currentUserProfile = profileState.userProfile;
       isMyProfile = currentUserProfile.isMe;
     }

     final displayedExperiences = allExperiences?.take(2).toList() ?? [];
     final totalExperienceCount = allExperiences?.length ?? 0;
     final showShowAllExperienceButton = totalExperienceCount > 2;

     final displayedEducations = allEducations?.take(2).toList() ?? [];
     final totalEducationCount = allEducations?.length ?? 0;
     final showShowAllEducationButton = totalEducationCount > 2;

     final displayedLicenses = allLicenses?.take(2).toList() ?? [];
     final totalLicenseCount = allLicenses?.length ?? 0;
     final showShowAllLicensesButton = totalLicenseCount > 2;

     final displayedSkills = allSkills?.take(2).toList() ?? [];
     final totalSkillCount = allSkills?.length ?? 0;
     final showShowAllSkillsButton = totalSkillCount > 2;

     final bool hasAboutText = aboutData?.about.isNotEmpty ?? false;
     final bool hasAboutSkills = aboutData?.skills.isNotEmpty ?? false;
     final bool showAboutSection = hasAboutText || hasAboutSkills;
     final bool hasResume = resumeUrl != null && resumeUrl.isNotEmpty;


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: ProfileAppBar(isMyProfile: isMyProfile),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(profileViewModelProvider.notifier).fetchUserProfile(widget.userId),
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
                       onPressed: () => ref.read(profileViewModelProvider.notifier).fetchUserProfile(widget.userId),
                       child: const Text('Retry'),
                     )
                   ],
                 ),
               ),
            ),
          ProfileLoaded(:final userProfile) => SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeaderWidget(userProfile: userProfile, userId: widget.userId),
                  ProfileActivityPreview(
                    userId: widget.userId,
                    userName: '${userProfile.firstName} ${userProfile.lastName}',
                    numberOfConnections: userProfile.numberOfConnections,
                    isMyProfile:  isMyProfile,
                  ),
              
                  if (hasResume)
                   SectionWidget(
                     title: "Resume",
                     onEditPressed: isMyProfile ? () => GoRouter.of(context).push('/add_resume') : null,
                     isMyProfile: isMyProfile, 
                     child: resumeUrl == null 
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
                                     resumeUrl,
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

                    // --- About Section ---
                    if (showAboutSection)
                      SectionWidget(
                        title: "About",
                        onEditPressed: isMyProfile ? () => GoRouter.of(context).push('/edit_about') : null,
                        isMyProfile: isMyProfile,
                        child: aboutData == null
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               if (hasAboutText)
                                 Padding(
                                   padding: EdgeInsets.only(bottom: hasAboutSkills ? 8.h : 0),
                                   child: Text(aboutData.about, style: TextStyles.font14_400Weight.copyWith(color: sectionTextColor)),
                                 ),
                               if (hasAboutSkills)
                                buildSkillsRowWidget(aboutData.skills, isDarkMode),
                ],)
                      ),

                   // --- Experience Section ---
                   SectionWidget(
                     title: "Experience",
                     onAddPressed: isMyProfile ? () => GoRouter.of(context).push('/add_new_position') : null,
                     onEditPressed: isMyProfile && allExperiences != null && allExperiences.isNotEmpty
                         ? () => GoRouter.of(context).push('/experience_list_page')
                         : null,
                     isMyProfile: isMyProfile,
                     child: allExperiences == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : (allExperiences.isEmpty && isMyProfile) 
                           ? EmptySectionPlaceholder(
                               icon: Icons.business_center_outlined,
                               titlePlaceholder: "Job Title",
                               subtitlePlaceholder: "Organization",
                               datePlaceholder: "YYYY - Present",
                               sectionSubtitle: "Showcase your accomplishments and get up to 2X as many profile views and connections",
                               callToActionText: "Add Experience",
                               onAddPressed: () => GoRouter.of(context).push('/add_new_position'),
                             )
                           : (allExperiences.isEmpty && !isMyProfile) 
                             ? Padding(padding: EdgeInsets.symmetric(vertical: 10.h), child: Text("No experience listed.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)))
                             : Column(
                               children: [
                                 Column(
                                  
                                   children: displayedExperiences.map((exp) => ExperienceListItem(
                                       exp: exp,
                                       isDarkMode: isDarkMode,
                                       showActions: false, 
                                     )).toList(),
                                 ),
                                 if (showShowAllExperienceButton) ...[
                                   Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3))),
                                   SizedBox(
                                     width: double.infinity,
                                     child: TextButton(
                                       // Anyone can view the full list
                                       onPressed: () => GoRouter.of(context).push('/experience_list_page', extra: {'userId': widget.userId, 'isMyProfile': isMyProfile}), 
                                       style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalExperienceCount experiences', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                     ),
                                   ),
                                 ]
                               ],
                             ),
                   ),

                    // --- Education Section ---
                    SectionWidget(
                      title: "Education",
                      onAddPressed: isMyProfile ? () => GoRouter.of(context).push('/add_new_education') : null,
                      onEditPressed: isMyProfile && allEducations != null && allEducations.isNotEmpty
                          ? () => GoRouter.of(context).push('/education_list_page')
                          : null,
                      isMyProfile: isMyProfile,
                      child: allEducations == null
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                           : (allEducations.isEmpty && isMyProfile)
                           ? EmptySectionPlaceholder(
                               icon: Icons.school_outlined,
                               titlePlaceholder: "School Name",
                               subtitlePlaceholder: "Degree, Field of Study",
                               datePlaceholder: "YYYY -<y_bin_721>",
                               callToActionText: "Add Education",
                               onAddPressed: () => GoRouter.of(context).push('/add_new_education'),
                             )
                           : (allEducations.isEmpty && !isMyProfile) 
                             ? Padding(padding: EdgeInsets.symmetric(vertical: 10.h), child: Text("No education listed.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)))
                             : Column(
                             children: [
                                Column(
                                  children: displayedEducations.map((edu) => EducationListItem(
                                    education: edu,
                                    isDarkMode: isDarkMode,
                                    showActions: false,
                                  )).toList()),
                                if (showShowAllEducationButton) ...[
                                  Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3))),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () => GoRouter.of(context).push('/education_list_page', extra: {'userId': widget.userId, 'isMyProfile': isMyProfile}), 
                                      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalEducationCount educations', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                    ),
                                  ),
                                ]
                             ],
                           ),
                    ),

                   // --- Licenses & Certifications Section ---
                   SectionWidget(
                     title: "Licenses & Certifications",
                     onAddPressed: isMyProfile ? () => GoRouter.of(context).push('/add_new_license') : null,
                     onEditPressed: isMyProfile && allLicenses != null && allLicenses.isNotEmpty
                         ? () => GoRouter.of(context).push('/license_list_page')
                         : null,
                     isMyProfile: isMyProfile,
                     child: allLicenses == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : (allLicenses.isEmpty && isMyProfile)
                           ? EmptySectionPlaceholder(
                               icon: Icons.card_membership_outlined,
                               titlePlaceholder: "License/Certification Name",
                               subtitlePlaceholder: "Issuing Organization",
                               datePlaceholder: "Issued<seg_44>",
                               callToActionText: "Add License",
                               onAddPressed: () => GoRouter.of(context).push('/add_new_license'),
                             )
                           : (allLicenses.isEmpty && !isMyProfile) 
                             ? Padding(padding: EdgeInsets.symmetric(vertical: 10.h), child: Text("No licenses or certifications listed.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)))
                             : Column(
                               children: [
                                 Column(
                                   children: displayedLicenses.map((lic) => LicenseListItem(
                                       license: lic,
                                       isDarkMode: isDarkMode,
                                       showActions: false, 
                                     )).toList(),
                                 ),
                                 if (showShowAllLicensesButton) ...[
                                   Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3))),
                                   SizedBox(
                                     width: double.infinity,
                                     child: TextButton(
                                       onPressed: () => GoRouter.of(context).push('/license_list_page', extra: {'userId': widget.userId, 'isMyProfile': isMyProfile}),
                                       style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalLicenseCount licenses', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                     ),
                                   ),
                                 ]
                               ],
                             ),
                   ),

                   // --- Skills Section ---
                   SectionWidget(
                     title: "Skills",
                     onAddPressed: isMyProfile ? () => GoRouter.of(context).push('/add_new_skill') : null,
                     onEditPressed: isMyProfile && allSkills != null && allSkills.isNotEmpty
                         ? () => GoRouter.of(context).push('/skills_list_page')
                         : null,
                     isMyProfile: isMyProfile,
                     child: allSkills == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : (allSkills.isEmpty && isMyProfile) 
                           ? EmptySectionPlaceholder(
                               icon: Icons.star_outline,
                               titlePlaceholder: "Skill Name",
                               subtitlePlaceholder: "e.g., Project Management",
                               datePlaceholder: "", 
                               callToActionText: "Add Skill",
                               onAddPressed: () => GoRouter.of(context).push('/add_new_skill'),
                             )
                           : (allSkills.isEmpty && !isMyProfile) 
                             ? Padding(padding: EdgeInsets.symmetric(vertical: 10.h), child: Text("No skills listed.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)))
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
                                         SkillListItem(
                                           skill: skill,
                                           isDarkMode: isDarkMode,
                                           showActions: false, 
                                         ),
                                         if (!isLastItem)
                                           Padding(
                                             padding: EdgeInsets.symmetric(vertical: 8.h),
                                             child: Divider(
                                               height: 1.h,
                                               thickness: 0.5,
                                               color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3),
                                             ),
                                           ),
                                       ],
                                     );
                                   }).toList(),
                                 ),
                                 if (showShowAllSkillsButton) ...[
                                   Padding(padding: EdgeInsets.only(top: 8.h), child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3))),
                                   SizedBox(
                                     width: double.infinity,
                                     child: TextButton(
                                       onPressed: () => GoRouter.of(context).push('/skills_list_page', extra: {'userId': widget.userId, 'isMyProfile': isMyProfile}),
                                       style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalSkillCount skills', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4.w), Icon(Icons.arrow_forward, size: 16.sp, color: sectionTextColor)])
                                     ),
                                   ),
                                 ]
                               ],
                             ),
                   ),

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
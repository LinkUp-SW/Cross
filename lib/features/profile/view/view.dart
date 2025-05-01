
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart'; 
import 'package:intl/intl.dart'; 
import 'package:link_up/features/profile/model/education_model.dart'; 
import 'package:link_up/features/profile/model/position_model.dart'; 
import 'package:link_up/features/profile/model/about_model.dart'; 
import 'package:link_up/features/profile/viewModel/profile_view_model.dart'; 
import 'package:link_up/features/profile/widgets/profile_app_bar_widget.dart';
import 'package:link_up/features/profile/widgets/profile_header_widget.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart'; 
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/shared/themes/colors.dart'; 
import 'package:link_up/shared/themes/text_styles.dart'; 
import 'package:cached_network_image/cached_network_image.dart'; 

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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Present';
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      return dateString; 
    }
  }

  String _formatDateRange(String startDate, String? endDate) {
    final startFormatted = _formatDate(startDate);
    final endFormatted = _formatDate(endDate);
    if (endFormatted == 'Present' || endFormatted.isEmpty) {
        return '$startFormatted - Present';
    }
    return '$startFormatted - $endFormatted';
  }

  Widget _buildSkillsRowWidget(List<String> skills, bool isDarkMode) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayedSkills = skills.take(5).toList();
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

  Widget _buildTopSkillsBox(List<String> skills, bool isDarkMode) {
     if (skills.isEmpty) {
       return const SizedBox.shrink();
     }
     final displayedSkills = skills.take(5).toList();
     String skillsText = displayedSkills.join(' • ');
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;

     return Padding(
       padding: EdgeInsets.only(top: 12.h), 
       child: InkWell( 
         onTap: () {
            // TODO: Navigate to skills page or edit skills
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Navigate to Skills (Not Implemented Yet)')));
         },
         child: Container(
           padding: EdgeInsets.all(12.w),
           decoration: BoxDecoration(
             
           ),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start, 
             children: [
               Padding(
                 padding: EdgeInsets.only(top: 2.h), 
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Icon(Icons.diamond_outlined, size: 20.sp, color: textColor),

                   ],
                 ),
               ),
               SizedBox(width: 12.w),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Add "Top skills" title here to match image
                     Text(
                        "Top skills",
                        style: TextStyles.font14_600Weight.copyWith(color: textColor)
                     ),
                     SizedBox(height: 4.h),
                     Text(
                       skillsText,
                       style: TextStyles.font14_500Weight.copyWith(color: textColor),
                     ),
                   ],
                 ),
               ),
               Padding(
                 padding: EdgeInsets.only(top: 2.h), 
                 child: Icon(Icons.arrow_forward, size: 18.sp, color: textColor),
               ),
             ],
           ),
         ),
       ),
     );
  }

  Widget _buildEducationItem(EducationModel edu, bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final logoUrl = edu.logoUrl;

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
              color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    placeholder: (context, url) => Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
                    errorWidget: (context, url, error) => Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
                    fit: BoxFit.contain,
                 )
                : Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.institution, style: TextStyles.font16_600Weight.copyWith(color: textColor)),
                SizedBox(height: 2.h),
                if (edu.degree.isNotEmpty || edu.fieldOfStudy.isNotEmpty)
                  Text('${edu.degree}${edu.degree.isNotEmpty && edu.fieldOfStudy.isNotEmpty ? ', ' : ''}${edu.fieldOfStudy}', style: TextStyles.font14_400Weight.copyWith(color: textColor)),
                SizedBox(height: 2.h),
                Text(_formatDateRange(edu.startDate, edu.endDate), style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
                SizedBox(height: 4.h),
                if (edu.grade != null && edu.grade!.isNotEmpty)
                  Text('Grade: ${edu.grade}', style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
                if (edu.activitesAndSocials != null && edu.activitesAndSocials!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: edu.grade != null && edu.grade!.isNotEmpty ? 4.h : 0),
                    child: Text('Activities and societies: ${edu.activitesAndSocials}', style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
                  ),
                if (edu.description != null && edu.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(edu.description!, style: TextStyles.font13_400Weight.copyWith(color: textColor)),
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
               color: isDarkMode ? AppColors.darkGrey: AppColors.lightGrey,
             ),
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)),
                     errorWidget: (context, url, error) => Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)),
                     fit: BoxFit.contain,
                  )
                 : Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)), // Placeholder Icon
           ),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(exp.title, style: TextStyles.font16_600Weight.copyWith(color: textColor)),
                 SizedBox(height: 2.h),
                 Text('${exp.companyName}${exp.employeeType.isNotEmpty ? ' · ${exp.employeeType}' : ''}', style: TextStyles.font14_400Weight.copyWith(color: textColor)),
                 SizedBox(height: 2.h),
                 Text(_formatDateRange(exp.startDate, exp.isCurrent ? null : exp.endDate), style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor)),
                 if (exp.location != null && exp.location!.isNotEmpty)
                   Padding(padding: EdgeInsets.only(top: 4.h), child: Text(exp.location!, style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor))),
                 if (exp.description != null && exp.description!.isNotEmpty)
                   Padding(padding: EdgeInsets.only(top: 4.h), child: Text(exp.description!, style: TextStyles.font13_400Weight.copyWith(color: textColor))),
                 if (exp.skills != null && exp.skills!.isNotEmpty)
                    _buildSkillsRowWidget(exp.skills!, isDarkMode),
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
    final aboutData = ref.watch(aboutDataProvider); 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final displayedEducations = allEducations?.take(2).toList() ?? [];
    final displayedExperiences = allExperiences?.take(2).toList() ?? [];
    final totalEducationCount = allEducations?.length ?? 0;
    final totalExperienceCount = allExperiences?.length ?? 0;
    final bool showShowAllEducationButton = totalEducationCount > 2;
    final bool showShowAllExperienceButton = totalExperienceCount > 2;

    final bool hasAboutText = aboutData?.about.isNotEmpty ?? false;
    final bool hasAboutSkills = aboutData?.skills.isNotEmpty ?? false;
    final bool showAboutSection = hasAboutText || hasAboutSkills;


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
                      Text('Error: $message', textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
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
                                 child: Text(
                                   aboutData.about,
                                   style: TextStyles.font14_400Weight.copyWith(
                                     color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                   ),
                                 ),
                               ),
                             if (hasAboutSkills)
                               _buildTopSkillsBox(aboutData.skills, isDarkMode),
                           ],
                         )
                    ),
                   if (!showAboutSection && aboutData != null)
                     SectionWidget(
                        title: "About",
                        onEditPressed: () => GoRouter.of(context).push('/edit_about'),
                        child: Padding(
                           padding: EdgeInsets.symmetric(vertical: 8.h),
                           child: Text(
                             "Add an About section to highlight your profile.",
                              style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                           ),
                        )
                     ),


                  SectionWidget(
                    title: "Education",
                    onAddPressed: () => GoRouter.of(context).push('/add_new_education'),
                    onEditPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Education List (Not Implemented Yet)')));
                       // TODO: Implement navigation to manage/edit education list
                    },
                    child: allEducations == null
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : Column(
                           children: [
                              if (displayedEducations.isEmpty)
                                const Padding(
                                   padding: EdgeInsets.symmetric(vertical: 16.0),
                                   child: Text("No education added yet."),
                                 )
                              else
                                Column(
                                   children: displayedEducations.map((edu) =>
                                     _buildEducationItem(edu, isDarkMode)
                                   ).toList(),
                                ),

                              if (showShowAllEducationButton)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3)), // Add divider before button
                                ),
                              if (showShowAllEducationButton)
                                SizedBox( 
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Show All Educations (Not Implemented Yet)')));
                                       // TODO: Implement navigation to show all education
                                    },
                                    style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Show all $totalEducationCount educations', style: TextStyles.font14_600Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.arrow_forward, size: 16.sp, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                      ],
                                    ),
                                  ),
                                ),
                           ],
                         ),
                  ),

                   SectionWidget(
                     title: "Experience",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_position'),
                     onEditPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Edit Experience List (Not Implemented Yet)')));
                       // TODO: Implement navigation to manage/edit experience list
                     },
                     child: allExperiences == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : Column(
                             children: [
                               if (displayedExperiences.isEmpty)
                                 const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text("No experience added yet."),
                                  )
                               else
                                 Column(
                                     children: displayedExperiences.map((exp) =>
                                       _buildExperienceItem(exp, isDarkMode)
                                     ).toList(),
                                  ),

                               if (showShowAllExperienceButton)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8.h),
                                   child: Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3)), // Add divider
                                 ),
                               if (showShowAllExperienceButton)
                                 SizedBox( 
                                   width: double.infinity,
                                   child: TextButton(
                                     onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(content: Text('Show All Experience (Not Implemented Yet)')));
                                       // TODO: Implement navigation to show all experience
                                     },
                                     style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Text('Show all $totalExperienceCount experiences', style: TextStyles.font14_600Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                                          SizedBox(width: 4.w),
                                         Icon(Icons.arrow_forward, size: 16.sp, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                       ],
                                     ),
                                   ),
                                 ),
                             ],
                           ),
                   ),

                  // Add other sections here (e.g., Licenses & Certifications)

                  SizedBox(height: 20.h), // Add some padding at the bottom
                ],
              ),
            ),
          // Initial state before loading starts
          ProfileInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
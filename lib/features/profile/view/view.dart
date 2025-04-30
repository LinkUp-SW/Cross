// profile/view/view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart'; // Ensure EducationModel is imported
 // Ensure EducationModel is imported
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/profile_app_bar_widget.dart';
import 'package:link_up/features/profile/widgets/profile_header_widget.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart'; // Ensure SectionWidget is imported
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/shared/themes/colors.dart'; // Import colors
import 'package:link_up/shared/themes/text_styles.dart'; // Import text styles
import 'package:cached_network_image/cached_network_image.dart'; // Import for network images

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
      // Call fetchUserProfile without arguments to fetch the logged-in user's profile
      ref.read(profileViewModelProvider.notifier).fetchUserProfile();
    });
  }

  // Helper function to format date string (YYYY-MM-DD) to "MMM yyyy"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Present';
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      // Format changed to match image "Jan 2025"
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      // Handle potential date parsing errors, maybe return original string or N/A
      return dateString; // Or return 'N/A' or '';
    }
  }

  // Helper function to create the date range string
  String _formatDateRange(String startDate, String? endDate) {
    final startFormatted = _formatDate(startDate);
    final endFormatted = _formatDate(endDate);
    // Handle case where end date might be null/empty even if not "present"
    if (endFormatted == 'Present' || endFormatted.isEmpty) {
        return '$startFormatted - Present';
    }
    return '$startFormatted - $endFormatted';
  }

  // Helper widget to display skills (simple text for now, matches image)
  Widget _buildSkillsRowWidget(List<String> skills, bool isDarkMode) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }
    // Combine skills with a separator, prefix with icon if desired
    String skillsText = skills.join(' • '); // Example separator
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
         crossAxisAlignment: CrossAxisAlignment.start, // Align icon and text nicely
         children: [
           // Optional Icon (like in the image)
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


  // Helper widget for each education item
  Widget _buildEducationItem(EducationModel edu, bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey; // Use lightGrey for less emphasis
    final logoUrl = edu.logoUrl;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 40.w, // Fixed width for logo area
            height: 40.h, // Fixed height for logo area
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.1), // Placeholder bg
              borderRadius: BorderRadius.circular(4.r), // Optional rounding
            ),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    placeholder: (context, url) => Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
                    errorWidget: (context, url, error) => Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
                    fit: BoxFit.contain, // Use contain or cover based on logo aspect ratios
                 )
                : Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20.sp)),
          ),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // School Name
                Text(
                  edu.institution,
                  style: TextStyles.font16_600Weight.copyWith(color: textColor), // Bold title
                ),
                SizedBox(height: 2.h),

                // Degree, Field of Study
                if (edu.degree.isNotEmpty || edu.fieldOfStudy.isNotEmpty)
                  Text(
                    '${edu.degree}${edu.degree.isNotEmpty && edu.fieldOfStudy.isNotEmpty ? ', ' : ''}${edu.fieldOfStudy}',
                    style: TextStyles.font14_400Weight.copyWith(color: textColor),
                  ),
                SizedBox(height: 2.h),

                // Dates
                Text(
                  _formatDateRange(edu.startDate, edu.endDate),
                  style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor), // Smaller, grey
                ),
                SizedBox(height: 4.h),

                // Grade
                if (edu.grade != null && edu.grade!.isNotEmpty)
                  Text(
                    'Grade: ${edu.grade}',
                    style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                  ),

                // Activities and Societies
                if (edu.activitesAndSocials != null && edu.activitesAndSocials!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: edu.grade != null && edu.grade!.isNotEmpty ? 4.h : 0),
                    child: Text(
                      // Show label or not based on preference
                      'Activities and societies: ${edu.activitesAndSocials}',
                      // edu.activitesAndSocials!, // Without label to match image closer
                      style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                    ),
                  ),

                 // Description
                 if (edu.description != null && edu.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      edu.description!,
                      style: TextStyles.font13_400Weight.copyWith(color: textColor),
                    ),
                  ),

                // Skills
                if (edu.skills != null && edu.skills!.isNotEmpty)
                  _buildSkillsRowWidget(edu.skills!, isDarkMode),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Experience Item Builder (Similar structure to Education) ---
  Widget _buildExperienceItem(PositionModel exp, bool isDarkMode) {
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;
     // Assuming PositionModel has similar logo logic or a company logo URL field
     // final logoUrl = exp.companyLogoUrl; // Example: replace with actual field if available

     return Padding(
       padding: EdgeInsets.symmetric(vertical: 8.h),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Logo Placeholder (replace with actual logo if available)
           Container(
             width: 40.w,
             height: 40.h,
             margin: EdgeInsets.only(right: 12.w),
             decoration: BoxDecoration(
               color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
               borderRadius: BorderRadius.circular(4.r),
             ),
             child: Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20.sp)),
             // Replace above with CachedNetworkImage if logoUrl exists
           ),
           // Details
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   exp.title,
                   style: TextStyles.font16_600Weight.copyWith(color: textColor), // Bold title
                 ),
                 SizedBox(height: 2.h),
                 Text(
                   // Combine Company Name and Employment Type?
                   '${exp.companyName}${exp.employeeType.isNotEmpty ? ' · ${exp.employeeType}' : ''}',
                   style: TextStyles.font14_400Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2.h),
                 Text(
                   _formatDateRange(exp.startDate, exp.isCurrent ? null : exp.endDate), // Use isCurrent flag
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
                  // Skills for Experience
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
    // Watch the full lists
    final allEducations = ref.watch(educationDataProvider);
    final allExperiences = ref.watch(experienceDataProvider); // Assuming similar provider exists
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine the lists to display (max 2)
    // Assuming providers return lists ordered latest first
    final displayedEducations = allEducations?.take(2).toList() ?? [];
    final displayedExperiences = allExperiences?.take(2).toList() ?? [];

    final totalEducationCount = allEducations?.length ?? 0;
    final totalExperienceCount = allExperiences?.length ?? 0;

    final bool showShowAllEducationButton = totalEducationCount > 2;
    final bool showShowAllExperienceButton = totalExperienceCount > 2;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground, // Background for whole page
      appBar: const ProfileAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileViewModelProvider.notifier).fetchUserProfile();
        },
        child: switch (profileState) {
          ProfileLoading() => const Center(child: CircularProgressIndicator()),
          ProfileError(:final message) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      Text('Error: $message', textAlign: TextAlign.center),
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

                  // Updated Education SectionWidget
                  SectionWidget(
                    title: "Education",
                    onAddPressed: () => GoRouter.of(context).push('/add_new_education'),
                    onEditPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Education (Not Implemented Yet)')));
                    },
                    child: allEducations == null // Handle loading state if provider is initially null
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : Column(
                            children: [
                              if (displayedEducations.isEmpty)
                                const Padding(
                                   padding: EdgeInsets.symmetric(vertical: 16.0),
                                   child: Text("No education added yet."),
                                 )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayedEducations.length,
                                  itemBuilder: (context, index) => _buildEducationItem(displayedEducations[index], isDarkMode),
                                  separatorBuilder: (context, index) => Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3)),
                                ),

                              if (showShowAllEducationButton)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: TextButton(
                                    onPressed: () {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Show All Educations (Not Implemented Yet)')));
                                    },
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Show all $totalEducationCount educations', style: TextStyles.font14_600Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                                        Icon(Icons.arrow_forward, size: 16.sp, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  // Updated Experience SectionWidget
                   SectionWidget(
                     title: "Experience",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_position'),
                     onEditPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Edit Experience (Not Implemented Yet)')));
                     },
                     child: allExperiences == null // Handle loading state
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : Column(
                             children: [
                               if (displayedExperiences.isEmpty)
                                 const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text("No experience added yet."),
                                  )
                               else
                                 ListView.separated(
                                   shrinkWrap: true,
                                   physics: const NeverScrollableScrollPhysics(),
                                   itemCount: displayedExperiences.length,
                                   itemBuilder: (context, index) => _buildExperienceItem(displayedExperiences[index], isDarkMode), // Use new builder
                                   separatorBuilder: (context, index) => Divider(height: 1.h, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3)),
                                 ),

                               if (showShowAllExperienceButton)
                                 Padding(
                                   padding: EdgeInsets.only(top: 8.h),
                                   child: TextButton(
                                     onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(content: Text('Show All Experience (Not Implemented Yet)')));
                                     },
                                     style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Text('Show all $totalExperienceCount experiences', style: TextStyles.font14_600Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                                         Icon(Icons.arrow_forward, size: 16.sp, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                       ],
                                     ),
                                   ),
                                 ),
                             ],
                           ),
                   ),

                  // TODO: Add other sections (About, Licenses, etc.) using SectionWidget similarly

                ],
              ),
            ),
          ProfileInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
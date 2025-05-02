// profile/view/view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/model/position_model.dart';
import 'package:link_up/features/profile/model/license_model.dart'; 
import 'package:link_up/features/profile/model/about_model.dart';
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

  // --- Helper Functions ---


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

  // Format date range for display
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
     final displayedSkills = skills.take(5).toList();
     String skillsText = displayedSkills.join(' • ');
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;

     return Padding(
       padding: EdgeInsets.only(top: 6),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Icon(Icons.star_outline, size: 14, color: secondaryTextColor),
           SizedBox(width: 6),
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


  // --- Item Builder Widgets ---


  Widget _buildEducationItem(EducationModel edu, bool isDarkMode) {
     final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
     final secondaryTextColor = AppColors.lightGrey;
     final logoUrl = edu.logoUrl;

     final DateTime? startDate = DateTime.tryParse(edu.startDate);
     final DateTime? endDate = edu.endDate != null ? DateTime.tryParse(edu.endDate!) : null;
     final bool isCurrentlyStudying = edu.endDate == null; 


     return Padding(
       padding: EdgeInsets.symmetric(vertical: 8),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             width: 40,
             height: 40,
             margin: EdgeInsets.only(right: 12),
             decoration: BoxDecoration(
               color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.1),
               borderRadius: BorderRadius.circular(4),
             ),
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Icon(Icons.school_outlined, color: secondaryTextColor, size: 20),
                     errorWidget: (context, url, error) => Icon(Icons.school_outlined, color: secondaryTextColor, size: 20),
                     fit: BoxFit.contain,
                   )
                 : Center(child: Icon(Icons.school_outlined, color: secondaryTextColor, size: 20)),
           ),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   edu.institution,
                   style: TextStyles.font18_600Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2),
                 if (edu.degree.isNotEmpty || edu.fieldOfStudy.isNotEmpty)
                   Text(
                     '${edu.degree}${edu.degree.isNotEmpty && edu.fieldOfStudy.isNotEmpty ? ', ' : ''}${edu.fieldOfStudy}',
                     style: TextStyles.font14_400Weight.copyWith(color: textColor),
                   ),
                 SizedBox(height: 2),
                 Text(
                  _formatDateRange(startDate, endDate, isCurrent: isCurrentlyStudying, doesNotExist: false),
                   style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                 ),
                 SizedBox(height: 4),
                 if (edu.grade != null && edu.grade!.isNotEmpty)
                   Text(
                     'Grade: ${edu.grade}',
                     style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                   ),
                 if (edu.activitesAndSocials != null && edu.activitesAndSocials!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: edu.grade != null && edu.grade!.isNotEmpty ? 4 : 0),
                     child: Text(
                       'Activities and societies: ${edu.activitesAndSocials}',
                       style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ),
                 if (edu.description != null && edu.description!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4),
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
       padding: EdgeInsets.symmetric(vertical: 8),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             width: 40,
             height: 40,
             margin: EdgeInsets.only(right: 12),
             decoration: BoxDecoration(
               color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.1),
               borderRadius: BorderRadius.circular(4),
             ),
             child: logoUrl != null && logoUrl.isNotEmpty
                 ? CachedNetworkImage(
                     imageUrl: logoUrl,
                     placeholder: (context, url) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20),
                     errorWidget: (context, url, error) => Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20),
                     fit: BoxFit.contain,
                   )
                 : Center(child: Icon(Icons.business_center_outlined, color: secondaryTextColor, size: 20)),
           ),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   exp.title,
                   style: TextStyles.font18_600Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2),
                 Text(
                   '${exp.companyName}${exp.employeeType.isNotEmpty ? ' · ${exp.employeeType}' : ''}',
                   style: TextStyles.font14_400Weight.copyWith(color: textColor),
                 ),
                 SizedBox(height: 2),
                 Text(
                   _formatDateRange(startDate, endDate, isCurrent: exp.isCurrent, doesNotExist: false),
                   style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                 ),
                 if (exp.location != null && exp.location!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4),
                     child: Text(
                       exp.location!,
                       style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ),
                 if (exp.description != null && exp.description!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4),
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    placeholder: (context, url) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20),
                    errorWidget: (context, url, error) => Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20),
                    fit: BoxFit.contain,
                  )
                : Center(child: Icon(Icons.card_membership_outlined, color: secondaryTextColor, size: 20)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lic.name,
                  style: TextStyles.font18_600Weight.copyWith(color: textColor),
                ),
                SizedBox(height: 2),
                Text(
                  lic.issuingOrganizationName,
                  style: TextStyles.font14_400Weight.copyWith(color: textColor),
                ),
                SizedBox(height: 2),
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
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Credential ID: ${lic.credentialId}',
                      style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                    ),
                  ),
                 if (lic.credentialUrl != null && lic.credentialUrl!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 4),
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

     final displayedEducations = allEducations?.take(2).toList() ?? [];
     final displayedExperiences = allExperiences?.take(2).toList() ?? [];
     final displayedLicenses = allLicenses?.take(2).toList() ?? []; 
     final totalEducationCount = allEducations?.length ?? 0;
     final totalExperienceCount = allExperiences?.length ?? 0;
     final totalLicenseCount = allLicenses?.length ?? 0;
     final bool showShowAllEducationButton = totalEducationCount > 2;
     final bool showShowAllExperienceButton = totalExperienceCount > 2;
     final bool showShowAllLicensesButton = totalLicenseCount > 2; 
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
                 padding: EdgeInsets.all(16),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text('Error: $message', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
                     SizedBox(height: 10),
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
                  // --- Header ---
                  ProfileHeaderWidget(userProfile: userProfile),

           

                  // Resume Section
                   SectionWidget(
                     title: "Resume",
                      onEditPressed: () => GoRouter.of(context).push('/add_resume'),
                     child: profileState is ProfileLoading 
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : hasResume
                             ? Column( 
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Container(
                                     height: 300,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                                     ),
                                     child: ClipRRect(
                                       borderRadius: BorderRadius.circular(8),
                                       child: PDF().cachedFromUrl(
                                         resumeUrl!,
                                         placeholder: (progress) => Center(child: Text('Loading: $progress %')),
                                         errorWidget: (error) => Center(child: Text('Error loading PDF: ${error.toString()}')),
                                       ),
                                     ),
                                   ),
                                   SizedBox(height: 8),
                                   Align(
                                     alignment: Alignment.centerRight,
                                     child: TextButton.icon(
                                       onPressed: () => GoRouter.of(context).push('/resume_viewer', extra: resumeUrl),
                                       icon: Icon(Icons.open_in_full, size: 16),
                                       label: Text('Open Fullscreen', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)),
                                     ),
                                   ),
                                 ],
                               )
                             : Padding( 
                                 padding: EdgeInsets.symmetric(vertical: 8),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text("No resume uploaded.", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey)),
                                     SizedBox(height: 8),
                                     OutlinedButton.icon(
                                       icon: Icon(Icons.add, size: 16, color: addTextColor),
                                       label: Text("Add Resume", style: TextStyles.font14_600Weight.copyWith(color: addTextColor)),
                                       style: addButtonStyle,
                                       onPressed: () => GoRouter.of(context).push('/add_resume'),
                                     )
                                   ],
                                 ),
                               ),
                   ),

                   // About Section
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
                                   padding: EdgeInsets.only(bottom: hasAboutSkills ? 0 : 8),
                                   child: Text(aboutData.about, style: TextStyles.font14_400Weight.copyWith(color: sectionTextColor)),
                                 ),
                               if (hasAboutSkills)
                                 _buildSkillsRowWidget(aboutData.skills, isDarkMode),
                             ],
                           )
                      ),

                   // Experience Section
                   SectionWidget(
                     title: "Experience",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_position'),
                     child: allExperiences == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : Column(
                             children: [
                               if (displayedExperiences.isEmpty)
                                 const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text("No experience added yet.")),
                               if (displayedExperiences.isNotEmpty)
                                 Column(children: displayedExperiences.map((exp) => _buildExperienceItem(exp, isDarkMode)).toList()),
                               if (showShowAllExperienceButton) ...[
                                 Padding(padding: EdgeInsets.only(top: 8), child: Divider(height: 1, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3))),
                                 SizedBox(
                                   width: double.infinity,
                                   child: TextButton(
                                     onPressed: () { /* TODO: Show All Experience */ },
                                     style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalExperienceCount experiences', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 16, color: sectionTextColor)])
                                   ),
                                 ),
                               ]
                             ],
                           ),
                   ),

                   // Education Section
                    SectionWidget(
                      title: "Education",
                      onAddPressed: () => GoRouter.of(context).push('/add_new_education'),
                      child: allEducations == null
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : Column(
                             children: [
                                if (displayedEducations.isEmpty)
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text("No education added yet.")),
                                if (displayedEducations.isNotEmpty)
                                  Column(children: displayedEducations.map((edu) => _buildEducationItem(edu, isDarkMode)).toList()),
                                if (showShowAllEducationButton) ...[
                                  Padding(padding: EdgeInsets.only(top: 8), child: Divider(height: 1, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3))),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () { /* TODO: Show All Education */ },
                                      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.center),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Show all $totalEducationCount educations', style: TextStyles.font14_600Weight.copyWith(color: sectionTextColor)), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 16, color: sectionTextColor)])
                                    ),
                                  ),
                                ]
                             ],
                           ),
                    ),

                  // Licenses & Certifications Section
                   SectionWidget(
                     title: "Licenses & Certifications",
                     onAddPressed: () => GoRouter.of(context).push('/add_new_license'),
                     child: allLicenses == null
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                         : Column(
                             children: [
                               if (displayedLicenses.isEmpty)
                                 const Padding(
                                     padding: EdgeInsets.symmetric(vertical: 16.0),
                                     child: Text("No licenses or certifications added yet.")
                                 ),
                               if (displayedLicenses.isNotEmpty)
                                 Column(
                                   children: displayedLicenses
                                       .map((lic) => _buildLicenseItem(lic, isDarkMode))
                                       .toList(),
                                 ),
                               if (showShowAllLicensesButton) ...[
                                 Padding(
                                   padding: EdgeInsets.only(top: 8),
                                   child: Divider(height: 1, thickness: 0.5, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.3))
                                 ),
                                 SizedBox(
                                   width: double.infinity,
                                   child: TextButton(
                                     onPressed: () { /* TODO: Implement Show All Licenses */ },
                                     style: TextButton.styleFrom(
                                         padding: EdgeInsets.symmetric(vertical: 8),
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
                                         SizedBox(width: 4),
                                         Icon(Icons.arrow_forward, size: 16, color: sectionTextColor)
                                       ]
                                     ),
                                   ),
                                 ),
                               ]
                             ],
                           ),
                   ),


                  SizedBox(height: 20),
                ],
              ),
            ),
          ProfileInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
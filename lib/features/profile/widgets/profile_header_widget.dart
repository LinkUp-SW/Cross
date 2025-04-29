import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/features/profile/widgets/bottom_sheet.dart';
import 'package:link_up/features/profile/state/profile_photo_state.dart';
import 'package:link_up/features/profile/viewModel/profile_photo_view_model.dart';
import 'package:link_up/features/profile/state/cover_photo_state.dart';
import 'package:link_up/features/profile/viewModel/cover_photo_view_model.dart';
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
// Import the specific provider, not the whole file if possible
import 'package:link_up/features/profile/viewModel/profile_view_model.dart' show educationDataProvider;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile userProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
  });

  // --- Bottom Sheet Handlers (Keep as is) ---
  void _handleProfilePicTap(BuildContext context, WidgetRef ref) {
     final ProfileState currentMainState = ref.read(profileViewModelProvider);
     String currentPhotoUrl = "";

     if (currentMainState is ProfileLoaded) {
       currentPhotoUrl = currentMainState.userProfile.profilePhotoUrl;
     }

     final options = [
       ReusableBottomSheetOption(
         icon: Icons.camera_alt_outlined,
         title: 'Take a photo',
         onTap: () { Navigator.pop(context); ref.read(profilePhotoViewModelProvider.notifier).pickProfilePhoto(ImageSource.camera); },
       ),
       ReusableBottomSheetOption(
         icon: Icons.arrow_upward,
         title: 'Upload from photos',
         onTap: () { Navigator.pop(context); ref.read(profilePhotoViewModelProvider.notifier).pickProfilePhoto(ImageSource.gallery); },
       ),
       if (currentPhotoUrl.isNotEmpty)
          ReusableBottomSheetOption(
            icon: Icons.delete_outline,
            title: 'Delete profile picture',
            onTap: () {
               Navigator.pop(context); // Close bottom sheet first
               showDialog(
                 context: context,
                 builder: (ctx) => AlertDialog(
                   title: const Text('Delete Photo?'),
                   content: const Text('Are you sure you want to delete your profile photo?'),
                   actions: [
                     TextButton(
                       child: const Text('Cancel'),
                       onPressed: () => Navigator.of(ctx).pop(),
                     ),
                     TextButton(
                       child: const Text('Delete', style: TextStyle(color: Colors.red)),
                       onPressed: () {
                         Navigator.of(ctx).pop();
                         ref.read(profilePhotoViewModelProvider.notifier).deleteProfilePhoto();
                       },
                     ),
                   ],
                 ),
               );
            },
          ),
     ];

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: options.map((option) => ListTile(
                 leading: option.icon != null ? Icon(option.icon, color: Theme.of(context).iconTheme.color) : null, // Use theme color
                 title: Text(option.title),
                 subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                 onTap: option.onTap,
              )).toList(),
            ),
          );
        },
      );
  }

  void _handleBackgroundPicTap(BuildContext context, WidgetRef ref) {
      ref.read(coverPhotoViewModelProvider.notifier).showCoverPhotoSourceDialog(context);
  }

  void _handleOpenToTap(BuildContext context) {
     final options = [
      ReusableBottomSheetOption(
        title: 'Finding a new job',
        subtitle: 'Show recruiters and others that you\'re open to work',
        onTap: () { /* TODO: Implement */ },
         icon: Icons.work_outline
      ),
      ReusableBottomSheetOption(
        title: 'Hiring',
        subtitle: 'Share that you\'re hiring and attract qualified candidates',
        onTap: () { /* TODO: Implement */ },
         icon: Icons.person_add_alt_1
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }
  // --- End Bottom Sheet Handlers ---


  // --- URL Launcher ---
  Future<void> _launchUrl(BuildContext context, String? urlString) async {
    log('[DEBUG] _launchUrl called with: $urlString');
    if (urlString == null || urlString.isEmpty) {
        log('[DEBUG] URL string is null or empty, returning.');
        return;
    }

    String urlToLaunch = urlString.trim();
    if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
      log('[DEBUG] URL missing scheme, prepending https://');
      urlToLaunch = 'https://$urlToLaunch';
    }

    Uri? url;
    try {
        url = Uri.parse(urlToLaunch);
        log('[DEBUG] Parsed URL: $url');
    } catch (e) {
       log('[DEBUG] Error parsing URL: $e');
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Invalid URL format: $urlString'), backgroundColor: Colors.red),
         );
       }
       return;
    }

    try {
        log('[DEBUG] Attempting to launch URL: $url');
        bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        log('[DEBUG] launchUrl result: $launched');
        if (!launched && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url'), backgroundColor: Colors.orange),
           );
        }
    } catch (e) {
       log('[DEBUG] Error launching URL: $e');
       if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error launching URL: ${e.toString().split(':').last.trim()}'), backgroundColor: Colors.red),
          );
       }
    }
  }
  // --- End URL Launcher ---


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final double backgroundHeight = 70.h;

    // --- Location String Logic ---
    String locationString = '';
    if (userProfile.city != null && userProfile.city!.isNotEmpty) {
        locationString += userProfile.city!;
    }
    if (userProfile.countryRegion != null && userProfile.countryRegion!.isNotEmpty) {
        if (locationString.isNotEmpty) locationString += ', ';
        locationString += userProfile.countryRegion!;
    }
    // --- End Location String Logic ---

    // --- Education Logic ---
    final List<EducationModel>? educationList = ref.watch(educationDataProvider);
    EducationModel? selectedEducation;
    // Check the flag and ID from userProfile, then search in educationList
    // if (userProfile.showEducationInIntro &&
    //     userProfile.selectedEducationId != null &&
    //     educationList != null) {
    //   try {
    //      selectedEducation = educationList.firstWhere(
    //          (edu) => edu.id == userProfile.selectedEducationId,
    //      );
    //      log('[DEBUG] Found selected education in header: ${selectedEducation.institution}');
    //   } catch (e) {
    //       log("[DEBUG] Error finding selected education ID ${userProfile.selectedEducationId} in list (header): $e");
    //       selectedEducation = null; // Ensure it's null if not found
    //   }
    // }
    // --- End Education Logic ---

    // --- Listener Logic (keep as is) ---
     ref.listen<ProfilePhotoState>(profilePhotoViewModelProvider, (previous, next) {
       if (next is ProfilePhotoUploading || next is ProfilePhotoDeleting) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next is ProfilePhotoUploading ? "Updating profile photo..." : "Deleting profile photo..."), duration: Duration(seconds: 1)),
         );
       } else if (next is ProfilePhotoError) {
           ScaffoldMessenger.of(context).removeCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Profile photo error: ${next.message}"), backgroundColor: Colors.red),
           );
       } else if (next is ProfilePhotoSuccess) {
           ScaffoldMessenger.of(context).removeCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.newImageUrl.isEmpty ? "Profile photo deleted!" : "Profile photo updated!"), backgroundColor: Colors.green),
           );
       } else if ((previous is ProfilePhotoUploading || previous is ProfilePhotoDeleting) && next is ProfilePhotoInitial) {
             ScaffoldMessenger.of(context).removeCurrentSnackBar();
       }
    });

     ref.listen<CoverPhotoState>(coverPhotoViewModelProvider, (previous, next) {
       if (next is CoverPhotoUploading || next is CoverPhotoDeleting) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next is CoverPhotoUploading ? "Updating cover photo..." : "Deleting cover photo..."), duration: Duration(seconds: 1)),
         );
       } else if (next is CoverPhotoError) {
           ScaffoldMessenger.of(context).removeCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Cover photo error: ${next.message}"), backgroundColor: Colors.red),
           );
       } else if (next is CoverPhotoSuccess) {
           ScaffoldMessenger.of(context).removeCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.newImageUrl.isEmpty ? "Cover photo deleted!" : "Cover photo updated!"), backgroundColor: Colors.green),
           );
       } else if ((previous is CoverPhotoUploading || previous is CoverPhotoDeleting) && next is CoverPhotoInitial) {
             ScaffoldMessenger.of(context).removeCurrentSnackBar();
       }
    });
    // --- End Listener Logic ---

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover Photo GestureDetector and Consumer
              GestureDetector(
                 onTap: () => _handleBackgroundPicTap(context, ref),
                 child: Consumer(
                    builder: (context, ref, _) {
                       final coverState = ref.watch(coverPhotoViewModelProvider);
                       bool isCoverProcessing = coverState is CoverPhotoUploading || coverState is CoverPhotoDeleting;
                       bool hasCoverUrl = userProfile.coverPhotoUrl.isNotEmpty;
                       return Container(
                         height: backgroundHeight,
                         width: double.infinity,
                         decoration: BoxDecoration(
                           color: Colors.grey[300],
                           image: hasCoverUrl
                               ? DecorationImage(
                                   image: NetworkImage(userProfile.coverPhotoUrl),
                                   fit: BoxFit.cover,
                                 )
                               : null,
                         ),
                         child: Stack(
                           children: [
                               if (!isCoverProcessing)
                                 Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CircleAvatar(
                                         radius: 12.r,
                                         backgroundColor: Colors.black.withOpacity(0.4),
                                         child: Icon(
                                           Icons.camera_alt_rounded,
                                           color: Colors.white,
                                           size: 14.sp,
                                         ),
                                       ),
                                    ),
                                 ),
                               if (isCoverProcessing)
                                 Container(
                                   color: Colors.black.withOpacity(0.5),
                                   child: const Center(
                                     child: SizedBox( // Constrain size of indicator
                                         height: 20,
                                         width: 20,
                                         child: CircularProgressIndicator(
                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                         strokeWidth: 2.0,
                                         ),
                                     ),
                                   ),
                                 ),
                           ],
                         ),
                       );
                    }
                 ),
               ),
              // Profile Picture Padding and GestureDetector
               Padding(
                 padding: EdgeInsets.only(top: 30.h, left: 16.w),
                 child: GestureDetector(
                   onTap: () => _handleProfilePicTap(context, ref),
                   child: Stack(
                     clipBehavior: Clip.none,
                     children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.white,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final photoState = ref.watch(profilePhotoViewModelProvider);
                              bool isProcessing = photoState is ProfilePhotoUploading || photoState is ProfilePhotoDeleting;
                              bool hasUrl = userProfile.profilePhotoUrl.isNotEmpty;

                              return CircleAvatar(
                                radius: 48.r,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: hasUrl ? NetworkImage(userProfile.profilePhotoUrl) : null,
                                child: !hasUrl ? Icon(Icons.person, size: 48.r, color: Colors.grey[600])
                                         : (isProcessing ? Container(
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle, // Apply shape to overlay
                                               color: Colors.black.withOpacity(0.5),
                                             ),
                                             child: const Center(
                                               child: SizedBox( // Constrain size
                                                 height: 24,
                                                 width: 24,
                                                 child: CircularProgressIndicator(
                                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                   strokeWidth: 2.0,
                                                 ),
                                               ),
                                             ),
                                           ) : null),
                              );
                            }
                          ),
                        ),
                       Positioned(
                         bottom: 0,
                         right: 0,
                         child: CircleAvatar(
                           radius: 10.r,
                           backgroundColor: AppColors.lightBlue,
                           child: Icon(Icons.add, size: 14.sp, color: AppColors.lightMain),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
              // Edit Icon Positioned
               Positioned(
                 top: backgroundHeight + 5.h,
                 right: 16.w,
                 child: GestureDetector(
                   onTap: () {
                     GoRouter.of(context).push('/edit_intro');
                   },
                   child: CircleAvatar(
                     radius: 16.r,
                     backgroundColor: isDarkMode ? AppColors.darkGrey.withOpacity(0.7) : AppColors.lightMain, // Adjusted background for dark mode visibility
                     child: Icon(
                       Icons.edit,
                       color: isDarkMode ? AppColors.darkTextColor : AppColors.lightSecondaryText,
                       size: 20.sp,
                     ),
                   ),
                 ),
               ),
            ],
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  '${userProfile.firstName} ${userProfile.lastName}',
                  style: TextStyles.font25_700Weight.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                ),
                 SizedBox(height: 2.h), // Reduced space before headline
                // Headline
                Text(
                  userProfile.headline,
                  style: TextStyles.font18_500Weight.copyWith(
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                  ),
                ),
                // Conditionally display selected education
                if (selectedEducation != null)
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: Row( // Use Row for Icon and Text
                       children: [
                         Icon(Icons.school, size: 16.sp, color: AppColors.lightGrey),
                         SizedBox(width: 6.w),
                         Expanded( // Allow text to wrap/ellipsis if needed
                           child: Text(
                               selectedEducation.institution,
                               style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                               overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
                   ),

                // Location String
                if (locationString.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: selectedEducation != null ? 3.h : 5.h), // Adjust top padding
                     child: Text(
                       locationString,
                       style: TextStyles.font13_400Weight.copyWith(color: AppColors.lightGrey),
                     ),
                   ),

                // Website Link
                if (userProfile.website != null && userProfile.website!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: InkWell(
                       onTap: () {
                           log('[DEBUG] Website InkWell tapped!');
                           _launchUrl(context, userProfile.website);
                       },
                       child: Text(
                         userProfile.website!,
                         style: TextStyles.font13_400Weight.copyWith(
                             color: AppColors.lightBlue,
                             decoration: TextDecoration.underline, // Add underline for links
                             decorationColor: AppColors.lightBlue), // Match underline color
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                   ),
                SizedBox(height: 10.h), // Increased space before connections

                // Connections Count
                Text(
                  '${userProfile.numberOfConnections} connections',
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 15.h), // Increased space before buttons
              ],
            ),
          ),
          // --- Buttons Section (Keep as is) ---
          Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.w),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: () => _handleOpenToTap(context),
                          style: isDarkMode
                              ? buttonStyles.wideBlueElevatedButtonDark()
                              : buttonStyles.wideBlueElevatedButton(),
                          child: Text(
                            "Open to",
                            style: TextStyles.font15_500Weight.copyWith(
                              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        flex: 4,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Add Section functionality
                          },
                          style: isDarkMode
                              ? buttonStyles.blueOutlinedButtonDark()
                              : buttonStyles.blueOutlinedButton(),
                          child: Text(
                            "Add section",
                            style: TextStyles.font15_500Weight.copyWith(
                              color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      SizedBox(
                        width: 30.r,
                        height: 35.r,
                        child: OutlinedButton(
                          onPressed: () {
                             // TODO: Implement More Options functionality
                          },
                          style: isDarkMode
                              ? buttonStyles.circularButtonDark()
                              : buttonStyles.circularButton(),
                          child: Icon(
                            Icons.more_horiz,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                 SizedBox(height: 5.h),
                 SizedBox(
                   width: double.infinity,
                   child: OutlinedButton(
                     onPressed: () {
                        // TODO: Implement Enhance Profile functionality
                     },
                     style: isDarkMode
                         ? buttonStyles.blueOutlinedButtonDark()
                         : buttonStyles.blueOutlinedButton(),
                     child: Text(
                       "Enhance profile",
                       style: TextStyles.font15_500Weight.copyWith(
                         color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                       ),
                     ),
                   ),
                 ),
                 SizedBox(height: 15.h),
               ],
             ),
           ),
          // --- End Buttons Section ---
        ],
      ),
    );
  }
}
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
import 'package:link_up/features/profile/state/profile_state.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:image_picker/image_picker.dart';


class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile userProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
  });

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
         onTap: () => ref.read(profilePhotoViewModelProvider.notifier).pickProfilePhoto(ImageSource.camera),
       ),
       ReusableBottomSheetOption(
         icon: Icons.arrow_upward,
         title: 'Upload from photos',
         onTap: () => ref.read(profilePhotoViewModelProvider.notifier).pickProfilePhoto(ImageSource.gallery),
       ),
       if (currentPhotoUrl.isNotEmpty)
          ReusableBottomSheetOption(
            icon: Icons.delete_outline,
            title: 'Delete profile picture',
            onTap: () {
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
     showReusableBottomSheet(context: context, options: options);
  }

  void _handleBackgroundPicTap(BuildContext context) {
    final options = [
      ReusableBottomSheetOption(
        icon: Icons.arrow_upward,
        title: 'Upload background photo',
        onTap: () {},
      ),
       ReusableBottomSheetOption(
        icon: Icons.delete_outline,
        title: 'Delete background photo',
        onTap: () {},
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }

  void _handleOpenToTap(BuildContext context) {
     final options = [
      ReusableBottomSheetOption(
        title: 'Finding a new job',
        subtitle: 'Show recruiters and others that you\'re open to work',
        onTap: () {},
      ),
      ReusableBottomSheetOption(
        title: 'Hiring',
        subtitle: 'Share that you\'re hiring and attract qualified candidates',
        onTap: () {},
      ),
    ];
    showReusableBottomSheet(context: context, options: options);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final double backgroundHeight = 70.h;

    String locationString = '';
    if (userProfile.city != null && userProfile.countryRegion != null) {
      locationString = '${userProfile.city}, ${userProfile.countryRegion}';
    } else if (userProfile.city != null) {
      locationString = userProfile.city!;
    } else if (userProfile.countryRegion != null) {
      locationString = userProfile.countryRegion!;
    }

     ref.listen<ProfilePhotoState>(profilePhotoViewModelProvider, (previous, next) {
       if (next is ProfilePhotoUploading || next is ProfilePhotoDeleting) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(next is ProfilePhotoUploading ? "Uploading photo..." : "Deleting photo..."), duration: Duration(seconds: 1)),
          );
       } else if (next is ProfilePhotoError) {
           ScaffoldMessenger.of(context).removeCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Operation failed: ${next.message}"), backgroundColor: Colors.red),
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
              GestureDetector(
                onTap: () => _handleBackgroundPicTap(context),
                child: Container(
                  height: backgroundHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    image: userProfile.coverPhotoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(userProfile.coverPhotoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: userProfile.coverPhotoUrl.isEmpty
                      ? const Center(child: Text(''))
                      : Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                            onPressed: () => _handleBackgroundPicTap(context),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, left: 16.w),
                child: GestureDetector(
                  onTap: () => _handleProfilePicTap(context, ref),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                       Consumer(
                         builder: (context, ref, _) {
                           final photoState = ref.watch(profilePhotoViewModelProvider);
                           bool isProcessing = photoState is ProfilePhotoUploading || photoState is ProfilePhotoDeleting;
                           return CircleAvatar(
                             radius: 50.r,
                             backgroundColor: Colors.white,
                             child: CircleAvatar(
                               radius: 48.r,
                               backgroundImage: userProfile.profilePhotoUrl.isNotEmpty
                                   ? NetworkImage(userProfile.profilePhotoUrl)
                                   : const AssetImage('assets/images/default-profile-picture.jpg') as ImageProvider,
                               backgroundColor: Colors.grey[300],
                               child: isProcessing
                                   ? Container(
                                       decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                       ),
                                       child: const Center(
                                          child: CircularProgressIndicator(
                                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                             strokeWidth: 2.0,
                                          ),
                                       ),
                                    )
                                   : null,
                             ),
                           );
                         }
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
              Positioned(
                top: backgroundHeight + 5.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () {
                    GoRouter.of(context).push('/edit_intro');
                  },
                  child: CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.lightMain,
                    child: Icon(
                      Icons.edit,
                      color: AppColors.lightSecondaryText,
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
                Text(
                  '${userProfile.firstName} ${userProfile.lastName}',
                  style: TextStyles.font25_700Weight.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                ),
                Text(
                  userProfile.headline,
                  style: TextStyles.font18_500Weight.copyWith(
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                  ),
                ),
                SizedBox(height: 5.h),
                 if (userProfile.education.isNotEmpty)
                   Text(
                     userProfile.education.first,
                     style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                   ),
                if (locationString.isNotEmpty)
                  Text(
                    locationString,
                    style: TextStyles.font13_400Weight.copyWith(color: AppColors.lightGrey),
                  ),
                SizedBox(height: 10.h),
                Text(
                  '${userProfile.numberOfConnections} connections',
                  style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                    onPressed: () {},
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
        ],
      ),
    );
  }
}
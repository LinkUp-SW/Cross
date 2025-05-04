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
import 'package:link_up/features/profile/viewModel/blocked_users_view_model.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/widgets/premium_plan_sheet.dart';
import 'package:link_up/features/profile/widgets/block_confirmation_dialog.dart';

import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile userProfile;
  final String userId;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
    required this.userId,
  });
  Future<void> _handleBlockUser(
      BuildContext context, WidgetRef ref, UserProfile userToBlock) async {
    final bool? confirmed = await showBlockConfirmationDialog(
      context,
      userToBlock.firstName,
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Blocking ${userToBlock.firstName}...'),
            duration: const Duration(seconds: 1)),
      );
      try {
        if (!context.mounted) return;
        context.pop();
        context.go('/');
        await ref
            .read(blockedUsersViewModelProvider.notifier)
            .blockUser(userId);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error blocking user: ${e.toString().replaceFirst("Exception: ", "")}'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showProfileOptionsBottomSheet(
      BuildContext context, WidgetRef ref, bool isMyProfile) {
    final List<ReusableBottomSheetOption> options = [];

    if (isMyProfile) {
      options.add(
        ReusableBottomSheetOption(
          icon: Icons.block,
          title: 'Blocked users',
          onTap: () {
            GoRouter.of(context).push('/blocked_users');
          },
        ),
      );
    }

    options.add(
      ReusableBottomSheetOption(
        icon: Icons.note,
        title: 'Contact Info',
        onTap: () {
          GoRouter.of(context).push('/contact_info', extra: userProfile);
        },
      ),
    );

    showReusableBottomSheet(
      context: context,
      options: options,
    );
  }

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
        onTap: () {
          Navigator.pop(context);
          ref
              .read(profilePhotoViewModelProvider.notifier)
              .pickProfilePhoto(ImageSource.camera);
        },
      ),
      ReusableBottomSheetOption(
        icon: Icons.arrow_upward,
        title: 'Upload from photos',
        onTap: () {
          Navigator.pop(context);
          ref
              .read(profilePhotoViewModelProvider.notifier)
              .pickProfilePhoto(ImageSource.gallery);
        },
      ),
      if (currentPhotoUrl.isNotEmpty)
        ReusableBottomSheetOption(
          icon: Icons.delete_outline,
          title: 'Delete profile picture',
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Photo?'),
                content: const Text(
                    'Are you sure you want to delete your profile photo?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  TextButton(
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ref
                          .read(profilePhotoViewModelProvider.notifier)
                          .deleteProfilePhoto();
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
            children: options
                .map((option) => ListTile(
                      leading: Icon(option.icon),
                      title: Text(option.title),
                      subtitle: option.subtitle != null
                          ? Text(option.subtitle!)
                          : null,
                      onTap: option.onTap,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  void _handleBackgroundPicTap(BuildContext context, WidgetRef ref) {
    ref
        .read(coverPhotoViewModelProvider.notifier)
        .showCoverPhotoSourceDialog(context);
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

  Future<void> _launchUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      return;
    }

    String urlToLaunch = urlString.trim();
    if (!urlToLaunch.startsWith('http://') &&
        !urlToLaunch.startsWith('https://')) {
      urlToLaunch = 'https://$urlToLaunch';
    }

    Uri? url;
    try {
      url = Uri.parse(urlToLaunch);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Invalid URL format: $urlString'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      bool launched =
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error launching URL: ${e.toString().split(':').last.trim()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final double backgroundHeight = 70.h;
    final bool isMe = userProfile.isMe;

    String locationString = '';
    if (userProfile.city != null && userProfile.city!.isNotEmpty) {
      locationString += userProfile.city!;
    }
    if (userProfile.countryRegion != null &&
        userProfile.countryRegion!.isNotEmpty) {
      if (locationString.isNotEmpty) locationString += ', ';
      locationString += userProfile.countryRegion!;
    }

    final List<EducationModel>? educationList =
        ref.watch(educationDataProvider);
    EducationModel? selectedEducation;

    ref.listen<ProfilePhotoState>(profilePhotoViewModelProvider,
        (previous, next) {
      if (next is ProfilePhotoUploading || next is ProfilePhotoDeleting) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next is ProfilePhotoUploading
                  ? "Updating profile photo..."
                  : "Deleting profile photo..."),
              duration: Duration(seconds: 1)),
        );
      } else if (next is ProfilePhotoError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Profile photo error: ${next.message}"),
              backgroundColor: Colors.red),
        );
      } else if (next is ProfilePhotoSuccess) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.newImageUrl.isEmpty
                  ? "Profile photo deleted!"
                  : "Profile photo updated!"),
              backgroundColor: Colors.green),
        );
      } else if ((previous is ProfilePhotoUploading ||
              previous is ProfilePhotoDeleting) &&
          next is ProfilePhotoInitial) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }
    });

    ref.listen<CoverPhotoState>(coverPhotoViewModelProvider, (previous, next) {
      if (next is CoverPhotoUploading || next is CoverPhotoDeleting) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next is CoverPhotoUploading
                  ? "Updating cover photo..."
                  : "Deleting cover photo..."),
              duration: Duration(seconds: 1)),
        );
      } else if (next is CoverPhotoError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Cover photo error: ${next.message}"),
              backgroundColor: Colors.red),
        );
      } else if (next is CoverPhotoSuccess) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.newImageUrl.isEmpty
                  ? "Cover photo deleted!"
                  : "Cover photo updated!"),
              backgroundColor: Colors.green),
        );
      } else if ((previous is CoverPhotoUploading ||
              previous is CoverPhotoDeleting) &&
          next is CoverPhotoInitial) {
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
                onTap:
                    isMe ? () => _handleBackgroundPicTap(context, ref) : null,
                child: Consumer(
                  builder: (context, ref, _) {
                    final coverState = ref.watch(coverPhotoViewModelProvider);
                    bool isCoverProcessing =
                        coverState is CoverPhotoUploading ||
                            coverState is CoverPhotoDeleting;
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
                          if (isMe && !isCoverProcessing)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  radius: 12.r,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.4),
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
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h, left: 16.w),
                child: GestureDetector(
                  onTap: isMe ? () => _handleProfilePicTap(context, ref) : null,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.white,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final photoState =
                                ref.watch(profilePhotoViewModelProvider);
                            bool isProcessing =
                                photoState is ProfilePhotoUploading ||
                                    photoState is ProfilePhotoDeleting;
                            bool hasUrl =
                                userProfile.profilePhotoUrl.isNotEmpty;

                            return CircleAvatar(
                              radius: 48.r,
                              backgroundColor: Colors.grey[300],
                              child: hasUrl
                                  ? ClipOval(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image(
                                            image: NetworkImage(
                                                userProfile.profilePhotoUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                              child: Icon(
                                                Icons.person_outline,
                                                size: 48.r,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          if (isProcessing)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 2.0,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 48.r,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      if (isMe)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 10.r,
                            backgroundColor: AppColors.lightBlue,
                            child: Icon(Icons.add,
                                size: 14.sp, color: AppColors.lightMain),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  top: backgroundHeight + 5.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push('/edit_intro');
                    },
                    child: CircleAvatar(
                      radius: 16.r,
                      backgroundColor:
                          isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                      child: Icon(
                        Icons.edit,
                        color: isDarkMode
                            ? AppColors.lightMain
                            : AppColors.lightSecondaryText,
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
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                ),
                Text(
                  userProfile.headline,
                  style: TextStyles.font18_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightTextColor,
                  ),
                ),
                SizedBox(height: 5.h),
                if (selectedEducation != null)
                  Text(
                    selectedEducation.institution,
                    style: TextStyles.font14_400Weight
                        .copyWith(color: AppColors.lightGrey),
                  ),
                if (locationString.isNotEmpty)
                  Text(
                    locationString,
                    style: TextStyles.font13_400Weight
                        .copyWith(color: AppColors.lightGrey),
                  ),
                if (userProfile.website != null &&
                    userProfile.website!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: InkWell(
                      onTap: () => _launchUrl(context, userProfile.website!),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link,
                              color: AppColors.lightBlue, size: 16.sp),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              userProfile.website!,
                              style: TextStyles.font13_400Weight.copyWith(
                                color: AppColors.lightBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 10.h),
                Text(
                  '${userProfile.numberOfConnections} connections',
                  style: TextStyles.font14_400Weight
                      .copyWith(color: AppColors.lightGrey),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: isMe
                ? _buildMyProfileActions(context, ref, buttonStyles, isDarkMode)
                : _buildOtherProfileActions(
                    context, ref, userProfile, buttonStyles, isDarkMode),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }

  Widget _buildMyProfileActions(BuildContext context, WidgetRef ref,
      LinkUpButtonStyles buttonStyles, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push('/user_posts_page');
                },
                style: isDarkMode
                    ? buttonStyles.wideBlueElevatedButtonDark()
                    : buttonStyles.wideBlueElevatedButton(),
                child: Text(
                  "Find a new job",
                  style: TextStyles.font15_500Weight.copyWith(
                    color:
                        isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              flex: 4,
              child: OutlinedButton(
                onPressed: () {
                  GoRouter.of(context).push('/add_profile_section');
                },
                style: isDarkMode
                    ? buttonStyles.blueOutlinedButtonDark()
                    : buttonStyles.blueOutlinedButton(),
                child: Text(
                  "Add section",
                  style: TextStyles.font15_500Weight.copyWith(
                    color:
                        isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
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
                  _showProfileOptionsBottomSheet(
                      context, ref, userProfile.isMe);
                },
                style: isDarkMode
                    ? buttonStyles.circularButtonDark()
                    : buttonStyles.circularButton(),
                child: Icon(
                  Icons.more_horiz,
                  color: isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.lightTextColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => showPremiumPlanSheet(context),
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
      ],
    );
  }

  Widget buildProfileActionButton({
    required BuildContext context,
    required bool isDarkMode,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required LinkUpButtonStyles buttonStyles,
  }) {
    return Expanded(
      flex: 4,
      child: ElevatedButton.icon(
          icon: Icon(icon, size: 18.sp),
          label: Text(label),
          onPressed: onPressed,
          style: (isDarkMode
              ? buttonStyles.wideBlueElevatedButtonDark()
              : buttonStyles.wideBlueElevatedButton())),
    );
  }

  Widget _buildOtherProfileActions(
      BuildContext context,
      WidgetRef ref,
      UserProfile otherUserProfile,
      LinkUpButtonStyles buttonStyles,
      bool isDarkMode) {
    log('--- _buildOtherProfileActions for ${otherUserProfile.firstName} ---');
    log('Input Flags: isInConnections=${otherUserProfile.isInConnections}, isInSentConnections=${otherUserProfile.isInSentConnections}, isInReceivedConnections=${otherUserProfile.isInReceivedConnections}, allowMessaging=${otherUserProfile.allowMessaging}');

    bool isConnected = otherUserProfile.isInConnections ?? false;
    bool isRequestSentByMe = otherUserProfile.isInSentConnections ?? false;
    bool isRequestReceivedByMe =
        otherUserProfile.isInReceivedConnections ?? false;
    bool isAlreadyFollowing = otherUserProfile.isAlreadyFollowing ?? false;
    bool allowMessaging = otherUserProfile.allowMessaging ?? false;
    bool isConnectByEmail = otherUserProfile.isConnectByEmail ?? false;
    bool isSubscribed = otherUserProfile.isSubscribed ?? false;
    bool viewUserSubscribed = otherUserProfile.viewUserSubscribed ?? false;
    bool followPrimary = otherUserProfile.followPrimary ?? false;

    String nameOfOneMutualConnection =
        otherUserProfile.nameOfOneMutualConnection ?? '';
    bool showConnectButton = !isConnected &&
        !isRequestSentByMe &&
        !isRequestReceivedByMe &&
        !followPrimary;
    bool showUnfollowButton = isAlreadyFollowing && followPrimary;
    bool showFollowButton = followPrimary && !isAlreadyFollowing;
    bool showPendingButton = isRequestSentByMe;
    bool showAcceptButton =
        isRequestReceivedByMe && !isConnected && !followPrimary;
    log('Calculated Conditions: isConnected=$isConnected, isRequestSentByMe=$isRequestSentByMe, isRequestReceivedByMe=$isRequestReceivedByMe');
    log('==> showConnectButton=$showConnectButton, showPendingButton=$showPendingButton');

    return Row(
      children: [
        // --- Connect Button ---
        if (showConnectButton)
          buildProfileActionButton(
            context: context,
            isDarkMode: isDarkMode,
            icon: Icons.add_circle_outline_rounded,
            label: "Connect",
            onPressed: () async {
              await ref
                  .read(profileViewModelProvider.notifier)
                  .sendConnectionRequest(userId);
            },
            buttonStyles: buttonStyles,
          ),
        // --- Accept Button ---
        if (showAcceptButton)
          buildProfileActionButton(
            context: context,
            isDarkMode: isDarkMode,
            icon: Icons.check_circle_outline_rounded,
            label: "Accept",
            onPressed: () async {
              ref
                  .read(profileViewModelProvider.notifier)
                  .acceptInvitation(userId);
            },
            buttonStyles: buttonStyles,
          ),
        // --- Pending Button ---
        if (showPendingButton)
          buildProfileActionButton(
            context: context,
            isDarkMode: isDarkMode,
            icon: Icons.hourglass_top_rounded,
            label: "Withdraw Connection",
            onPressed: () async {
              await ref
                  .read(profileViewModelProvider.notifier)
                  .withdrawConnectionRequest(userId);
            },
            buttonStyles: buttonStyles,
          ),
        // --- UnFollow Button ---
        if (showUnfollowButton)
          buildProfileActionButton(
            context: context,
            isDarkMode: isDarkMode,
            icon: Icons.cancel_outlined,
            label: "Unfollow",
            onPressed: () async {
              await ref
                  .read(profileViewModelProvider.notifier)
                  .unfollowUser(userId);
            },
            buttonStyles: buttonStyles,
          ),
        // --- Follow Button ---
        if (showFollowButton)
          buildProfileActionButton(
            context: context,
            isDarkMode: isDarkMode,
            icon: Icons.add_circle_outline_rounded,
            label: "Follow",
            onPressed: () async {
              await ref
                  .read(profileViewModelProvider.notifier)
                  .followUser(userId);
            },
            buttonStyles: buttonStyles,
          ),

        if (showConnectButton ||
            showPendingButton ||
            showFollowButton ||
            showAcceptButton ||
            showUnfollowButton)
          SizedBox(width: 6.w),
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
              icon: Icon(
                Icons.message,
                size: 18.sp,
                color: AppColors.lightBlue,
              ),
              label: const Text(
                "Message",
                style: TextStyle(color: AppColors.lightBlue),
              ),
              onPressed: () {
                final bool canActuallyMessage =
                    otherUserProfile.allowMessaging ?? false;
                log('Message button clicked for ${otherUserProfile.firstName} - allowMessaging: $canActuallyMessage');

                if (canActuallyMessage || isConnected || viewUserSubscribed) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'TODO: Open chat with ${otherUserProfile.firstName}')));
                } else {
                  showPremiumPlanSheet(context);
                }
              },
              style: (isDarkMode
                      ? buttonStyles.blueOutlinedButtonDark()
                      : buttonStyles.blueOutlinedButton())
                  .copyWith(
                foregroundColor:
                    MaterialStateProperty.all(AppColors.lightTextColor),
                side: MaterialStateProperty.all(
                    BorderSide(color: AppColors.darkBlue)),
              )),
        ),

        SizedBox(width: 8.w),

        SizedBox(
          width: 30.r,
          height: 35.r,
          child: OutlinedButton(
            onPressed: () {
              log('More button clicked for ${otherUserProfile.firstName}');

              final List<ReusableBottomSheetOption> options = [
                if (followPrimary && !isConnected && !isRequestSentByMe)
                  ReusableBottomSheetOption(
                    icon: Icons.person_add_outlined,
                    title: 'Connect',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .sendConnectionRequest(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                if (followPrimary && !isConnected && isRequestSentByMe)
                  ReusableBottomSheetOption(
                    icon: Icons.person_remove_outlined,
                    title: 'Withdraw Request',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .withdrawConnectionRequest(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                if (!followPrimary && !isConnected && !isAlreadyFollowing)
                  ReusableBottomSheetOption(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Follow',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .followUser(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                if (isConnected && followPrimary)
                  ReusableBottomSheetOption(
                    icon: Icons.person_remove_alt_1_outlined,
                    title: 'Remove Connection',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .removeConnection(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                if (isAlreadyFollowing && !followPrimary)
                  ReusableBottomSheetOption(
                    icon: Icons.person_remove_outlined,
                    title: 'Unfollow',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .unfollowUser(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                if (followPrimary && isRequestReceivedByMe)
                  ReusableBottomSheetOption(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Accept Connection Request',
                    onTap: () async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .acceptInvitation(userId);
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                ReusableBottomSheetOption(
                    icon: Icons.block,
                    title: 'Block User',
                    onTap: () {
                      _handleBlockUser(context, ref, otherUserProfile);
                    }),
                ReusableBottomSheetOption(
                    icon: Icons.note_outlined,
                    title: 'Contact Info',
                    onTap: () {
                      log('Contact Info option tapped');
                      GoRouter.of(context)
                          .push('/contact_info', extra: otherUserProfile);
                    }),
              ];

              showReusableBottomSheet(context: context, options: options);
            },
            style: (isDarkMode
                    ? buttonStyles.circularButtonDark()
                    : buttonStyles.circularButton())
                .copyWith(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
            ),
            child: Icon(
              Icons.more_horiz,
              color: isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.lightTextColor,
            ),
          ),
        )
      ],
    );
  }
}

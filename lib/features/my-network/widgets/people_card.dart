import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/people_card_model.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/snackbar_content.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';

class PeopleCard extends ConsumerStatefulWidget {
  final PeopleCardsModel data;
  final bool? isEducationCard;

  const PeopleCard({
    super.key,
    required this.data,
    this.isEducationCard,
  });

  @override
  ConsumerState<PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends ConsumerState<PeopleCard> {
  bool isConnecting = false;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shadowColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      elevation: 3.0.r,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.r),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
          width: 0.5.w,
        ),
      ),
      child: Column(
        spacing: 15.h,
        children: [
          Stack(
            clipBehavior: Clip.none, // Important to allow overflow
            alignment:
                Alignment.bottomCenter, // Align profile pic to bottom center
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                ),
                child: Image(
                  image: widget.data.coverPicture != null
                      ? NetworkImage(widget.data.coverPicture!)
                      : AssetImage('assets/images/default-cover-picture.png')
                          as ImageProvider,
                  width: double.infinity,
                  height: 60.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Profile image - positioned to overlap
              Positioned(
                bottom: -25.h,
                right: 32.w,
                child: CircleAvatar(
                  radius: 45.r,
                  foregroundImage: widget.data.profilePicture != null
                      ? NetworkImage(widget.data.profilePicture!)
                      : AssetImage('assets/images/default-profile-picture.jpg')
                          as ImageProvider,
                ),
              ),
              // Cancel Button
              Positioned(
                top: 5.h,
                right: 3.w,
                child: InkWell(
                  onTap: () async {
                    final isEducationCard = widget.isEducationCard ?? false;
                    final foundReplacement = await ref
                        .read(growTabViewModelProvider.notifier)
                        .getReplacementPerson(widget.data.cardId,
                            isEducationCard ? 'education' : 'work_experience');

                    if (!foundReplacement) {
                      openSnackbar(
                          child: SnackbarContent(
                              message: 'No more people you may know available',
                              icon: Icons.info));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: AppColors.fineLinesGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(),
          Column(
            children: [
              Text(
                "${widget.data.firstName} ${widget.data.lastName}",
                style: TextStyles.font15_700Weight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.0.w,
                ),
                child: Text(
                  widget.data.title ?? '',
                  style: TextStyles.font15_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkGrey
                        : AppColors.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.data.whoCanSendMeInvitation == "Everyone") {
                      if (isConnecting) {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          builder: (context) => Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkMain
                                  : AppColors.lightMain,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5.h,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Text(
                                    'Withdraw Invitation',
                                    style: TextStyles.font15_700Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightTextColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Text(
                                    "If you withdraw now, you won't be able to resend to ${widget.data.firstName} ${widget.data.lastName} for up to 3 weeks",
                                    style: TextStyles.font13_500Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightTextColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 5.h),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          style: isDarkMode
                                              ? LinkUpButtonStyles()
                                                  .myNetworkScreenConnectDark()
                                              : LinkUpButtonStyles()
                                                  .myNetworkScreenConnectLight(),
                                          child: Text('Cancel'),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 5.h),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(growTabViewModelProvider
                                                    .notifier)
                                                .withdrawInvitation(
                                                  widget.data.cardId,
                                                );
                                            setState(
                                              () {
                                                isConnecting = !isConnecting;
                                              },
                                            );
                                            context.pop();
                                          },
                                          style: isDarkMode
                                              ? LinkUpButtonStyles()
                                                  .profileOpenToDark()
                                              : LinkUpButtonStyles()
                                                  .profileOpenToLight(),
                                          child: Text('Withdraw'),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        ref
                            .read(growTabViewModelProvider.notifier)
                            .sendConnectionRequest(widget.data.cardId);
                        setState(
                          () {
                            isConnecting = !isConnecting;
                          },
                        );
                      }
                    }
                  },
                  style: isDarkMode
                      ? isConnecting
                          ? LinkUpButtonStyles()
                              .myNetworkScreenConnectDarkPressed()
                          : LinkUpButtonStyles().myNetworkScreenConnectDark()
                      : isConnecting
                          ? LinkUpButtonStyles()
                              .myNetworkScreenConnectLightPressed()
                          : LinkUpButtonStyles()
                              .myNetworkScreenConnectLightPressed(),
                  child: Text(isConnecting ? "Pending" : "Connect"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

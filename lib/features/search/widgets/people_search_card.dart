import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/search/model/people_search_card_model.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class PeopleSearchCard extends ConsumerStatefulWidget {
  final PeopleCardModel data;
  final bool isFirstConnection;
  const PeopleSearchCard({
    super.key,
    required this.data,
    required this.isFirstConnection,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PeopleSearchCardState();
}

class _PeopleSearchCardState extends ConsumerState<PeopleSearchCard> {
  bool isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 10.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              child: CircleAvatar(
                radius: 30.r,
                foregroundImage: widget.data.profilePhoto != null &&
                        widget.data.profilePhoto!.isNotEmpty
                    ? NetworkImage(widget.data.profilePhoto!)
                    : AssetImage('assets/images/default-profile-picture.png')
                        as ImageProvider,
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  border: Border(
                    bottom: BorderSide(
                      width: 0.3.w,
                      color:
                          isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4.h,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${widget.data.name} ",
                                  style: TextStyles.font15_500Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightTextColor,
                                  ),
                                ),
                                Text(
                                  ". ${widget.data.connectionDegree}",
                                  style: TextStyles.font14_500Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.data.headline!,
                              style: TextStyles.font14_500Weight.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Text(
                              widget.data.location!,
                              style: TextStyles.font14_500Weight.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.lightGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            widget.data.mutualConnectionsCount > 0
                                ? Row(
                                    spacing: 5.w,
                                    children: [
                                      CircleAvatar(
                                        radius: 10.r,
                                        foregroundImage: widget.data
                                                        .firstMutualConnectionPicture !=
                                                    null &&
                                                widget
                                                    .data
                                                    .firstMutualConnectionPicture!
                                                    .isNotEmpty
                                            ? NetworkImage(widget.data
                                                .firstMutualConnectionPicture!)
                                            : AssetImage(
                                                    'assets/images/default-profile-picture.png')
                                                as ImageProvider,
                                      ),
                                      Expanded(
                                        child: Text(
                                          widget.data.mutualConnectionsCount -
                                                      1 >
                                                  0
                                              ? "${widget.data.firstMutualConnectionName} and ${widget.data.mutualConnectionsCount - 1} mutual connections"
                                              : "${widget.data.firstMutualConnectionName} is a mutual connections",
                                          style: TextStyles.font13_500Weight
                                              .copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkSecondaryText
                                                : AppColors.lightTextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "No mutual connections",
                                    style: TextStyles.font13_500Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7.w),
                        child: Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkMain
                                : AppColors.lightMain,
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.darkGrey
                                  : AppColors.lightGrey,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: widget.data.connectionDegree == '1st' ||
                                  widget
                                      .data.isInReceivedConnectionInvitations ||
                                  widget.data.isInSentConnectionInvitations
                              ? IconButton(
                                  onPressed: () {},
                                  icon: Transform.rotate(
                                    angle:
                                        -pi / 4, // 45 degrees counterclockwise
                                    child: Icon(
                                      Icons.send,
                                      size: 20.r,
                                      color: isDarkMode
                                          ? AppColors.darkTextColor
                                          : AppColors.lightTextColor,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    if (!isConnecting) {
                                      ref
                                          .read(
                                              growTabViewModelProvider.notifier)
                                          .sendConnectionRequest(
                                              widget.data.cardId);
                                      setState(() {
                                        isConnecting = !isConnecting;
                                      });
                                    } else {
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 5.h,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Text(
                                                  'Withdraw Invitation',
                                                  style: TextStyles
                                                      .font15_700Weight
                                                      .copyWith(
                                                    color: isDarkMode
                                                        ? AppColors
                                                            .darkSecondaryText
                                                        : AppColors
                                                            .lightTextColor,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Text(
                                                  "If you withdraw now, you won't be able to resend to ${widget.data.name} for up to 3 weeks",
                                                  style: TextStyles
                                                      .font13_500Weight
                                                      .copyWith(
                                                    color: isDarkMode
                                                        ? AppColors
                                                            .darkSecondaryText
                                                        : AppColors
                                                            .lightTextColor,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                              vertical: 5.h),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                              vertical: 5.h),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                  growTabViewModelProvider
                                                                      .notifier)
                                                              .withdrawInvitation(
                                                                widget.data
                                                                    .cardId,
                                                              );
                                                          setState(
                                                            () {
                                                              isConnecting =
                                                                  !isConnecting;
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
                                    }
                                  },
                                  icon: Icon(
                                    isConnecting
                                        ? Icons.schedule
                                        : Icons.person_add,
                                    size: 20.r,
                                    color: isDarkMode
                                        ? AppColors.darkTextColor
                                        : AppColors.lightTextColor,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

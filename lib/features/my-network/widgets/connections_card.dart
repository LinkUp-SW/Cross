import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/connections_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/confirmation_pop_up.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';
import 'dart:math' show pi;
import 'package:go_router/go_router.dart';

class ConnectionsCard extends ConsumerWidget {
  final ConnectionsCardModel data;
  const ConnectionsCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        border: Border(
          bottom: BorderSide(
            width: 0.3.w,
            color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 12.w,
                children: [
                  InkWell(
                    onTap: () {
                      context.push('/profile', extra: data.cardId);
                    },
                    child: CircleAvatar(
                      radius: 30.r,
                      foregroundImage: data.profilePicture == ""
                          ? AssetImage(
                              'assets/images/default-profile-picture.png')
                          : NetworkImage(
                              data.profilePicture,
                            ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.push('/profile', extra: data.cardId);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            "${data.firstName} ${data.lastName}",
                            style: TextStyles.font15_700Weight,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Title
                          Text(
                            data.title,
                            style: TextStyles.font13_500Weight.copyWith(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          // Connection date
                          Text(
                            'Connected ${getDaysDifference(data.connectionDate)}',
                            style: TextStyles.font12_500Weight.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Remove connection & Message icons
            Row(
              children: [
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationPopUp(
                        title: 'Remove connection',
                        content:
                            'Are you sure you want to remove your connection with ${data.firstName} ${data.lastName}?',
                        buttonText: 'Remove',
                        buttonFunctionality: () {
                          Navigator.of(context).pop();
                          ref
                              .read(connectionsScreenViewModelProvider.notifier)
                              .removeConnection(data.cardId);
                        },
                      ),
                    ),
                  },
                  icon: Icon(
                    Icons.more_vert,
                    size: 25.r,
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => {},
                  icon: Transform.rotate(
                    angle: -pi / 4, // 45 degrees counterclockwise
                    child: Icon(
                      Icons.send,
                      size: 25.r,
                      color: isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.lightTextColor,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

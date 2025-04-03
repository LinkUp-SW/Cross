import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/connections_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';
import 'package:link_up/features/my-network/viewModel/manage_my_network_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/confirmation_pop_up.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class ConnectionsCard extends ConsumerWidget {
  final ConnectionsCardModel data;
  final bool isDarkMode;
  const ConnectionsCard({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  CircleAvatar(
                    radius: 30.r,
                    foregroundImage: NetworkImage(
                      data.profilePicture,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          "${data.firstName} ${data.lastName}",
                          style: TextStyles.font15_700Weight,
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
                          getDaysDifference(data.connectionDate),
                          style: TextStyles.font12_500Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextColor
                                : AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Remove connection & Message icons
            Row(
              spacing: 8.w,
              children: [
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationPopUp(
                        title: 'Remove connection',
                        content:
                            'Are you sure you want to remove your connection with ${data.firstName} ${data.lastName}?',
                        isDarkMode: isDarkMode,
                        buttonText: 'Remove',
                        buttonFunctionality: () {
                          Navigator.of(context).pop();
                          ref
                              .read(connectionsScreenViewModelProvider.notifier)
                              .removeConnection(data.cardId);
                          ref
                              .read(manageMyNetworkScreenViewModelProvider
                                  .notifier)
                              .getManageMyNetworkScreenCounts();
                        },
                      ),
                    ),
                  },
                  icon: Icon(
                    Icons.person_off,
                    size: 25.r,
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => {},
                  icon: Icon(
                    Icons.send,
                    size: 25.r,
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

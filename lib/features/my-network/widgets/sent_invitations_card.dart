import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/invitations_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/confirmation_pop_up.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class SentInvitationsCard extends ConsumerWidget {
  final InvitationsCardModel data;
  final bool isDarkMode;
  const SentInvitationsCard({
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
          spacing: 10.w,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8.w,
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
                        Text(
                          "${data.firstName} ${data.lastName}",
                          style: TextStyles.font14_500Weight,
                        ),
                        Text(
                          data.title,
                          style: TextStyles.font13_500Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkGrey
                                : AppColors.lightSecondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          "Sent ${getDaysDifference(data.daysCount)}",
                          style: TextStyles.font12_500Weight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationPopUp(
                      title: 'Withdraw invitation',
                      content:
                          'Are you sure you want to withdraw your connection invitation to ${data.firstName} ${data.lastName}?',
                      isDarkMode: isDarkMode,
                      buttonText: 'Withdraw',
                      buttonFunctionality: () {
                        Navigator.of(context).pop();
                        ref
                            .read(invitationsScreenViewModelProvider.notifier)
                            .withdrawInvitation(data.cardId);
                      },
                    ),
                  );
                },
                child: Text(
                  "Withdraw",
                  style: TextStyles.font15_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
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

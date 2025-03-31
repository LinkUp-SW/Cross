import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/invitations_screen_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class ReceivedInvitationsCard extends ConsumerWidget {
  final InvitationsCardModel data;
  final bool isDarkMode;
  const ReceivedInvitationsCard({
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image(
                      width: 50.w,
                      height: 50.h,
                      image: NetworkImage(
                        data.profilePicture,
                      ),
                      fit: BoxFit.fitWidth,
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
                          "${data.mutualsCount} mutual connections",
                          style: TextStyles.font12_500Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkGrey
                                : AppColors.lightSecondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          getDaysDifference(data.daysCount),
                          style: TextStyles.font12_500Weight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: 8.w,
              children: [
                Material(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      ref
                          .read(invitationsScreenViewModelProvider.notifier)
                          .acceptInvitation(data.cardId);
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkMain
                            : AppColors.lightMain,
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkBlue
                              : AppColors.lightBlue,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: isDarkMode
                            ? AppColors.darkBlue
                            : AppColors.lightBlue,
                        size: 21.h,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      ref
                          .read(invitationsScreenViewModelProvider.notifier)
                          .ignoreInvitation(data.cardId);
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.r),
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
                      child: Icon(
                        Icons.close,
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightGrey,
                        size: 21.h,
                      ),
                    ),
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

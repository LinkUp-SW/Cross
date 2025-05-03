import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/people_i_follow_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/people_i_follow_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/confirmation_pop_up.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:go_router/go_router.dart';

class FollowingCard extends ConsumerWidget {
  final FollowingCardModel data;
  const FollowingCard({
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
          spacing: 10.w,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8.w,
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
                          Text(
                            "${data.firstName} ${data.lastName}",
                            style: TextStyles.font14_500Weight,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data.title,
                            style: TextStyles.font13_500Weight.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
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
                      title: 'Unfollowing',
                      content:
                          'Are you sure you want to unfollow ${data.firstName} ${data.lastName}?',
                      buttonText: 'Unfollow',
                      buttonFunctionality: () {
                        Navigator.of(context).pop();
                        ref
                            .read(peopleIFollowScreenViewModelProvider.notifier)
                            .unfollow(data.cardId);
                      },
                    ),
                  );
                },
                child: Text(
                  "Following",
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

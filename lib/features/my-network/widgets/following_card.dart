import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/people_i_follow_screen_model.dart';
import 'package:link_up/features/my-network/viewModel/people_i_follow_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/confirmation_pop_up.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

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
            width: 0.3,
            color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  CircleAvatar(
                    radius: 30,
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
                                ? AppColors.darkSecondaryText
                                : AppColors.lightTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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

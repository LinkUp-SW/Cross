import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/jobs_screen_utils.dart';

class JobsCard extends ConsumerWidget {
  final bool isDarkMode;
  final JobsCardModel data;

  JobsCard({
    super.key,
    required this.isDarkMode,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Image(
                      image: AssetImage(
                        data.companyPicture,
                      ),
                      width: 40,
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.jobTitle,
                          style: TextStyles.font15_700Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkSecondaryText
                                : AppColors.lightTextColor,
                          ),
                        ),
                        Text(
                          data.companyName,
                          style: TextStyles.font14_500Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkSecondaryText
                                : AppColors.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.close,
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              '${data.city}, ${data.country}, ${data.workType}',
              style: TextStyles.font15_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.lightSecondaryText,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 60,
              bottom: 5,
            ),
            child: Text(
              getDaysDifference(data.postDate),
              style: TextStyles.font13_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.lightSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
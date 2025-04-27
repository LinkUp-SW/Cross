import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/search/model/people_search_card_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class PeopleSearchCard extends ConsumerWidget {
  final PeopleCardModel data;
  final bool isFirstConnection;
  final VoidCallback buttonFunctionality;
  const PeopleSearchCard({
    super.key,
    required this.data,
    required this.isFirstConnection,
    required this.buttonFunctionality,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                foregroundImage: data.profilePhoto != null
                    ? NetworkImage(data.profilePhoto!)
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
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${data.name} ",
                                  style: TextStyles.font15_500Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightTextColor,
                                  ),
                                ),
                                Text(
                                  ". ${data.connectionDegree}",
                                  style: TextStyles.font14_500Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              data.headline!,
                              style: TextStyles.font14_500Weight.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Text(
                              data.location,
                              style: TextStyles.font14_500Weight.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.lightGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Row(
                              spacing: 5.w,
                              children: [
                                CircleAvatar(
                                  radius: 10.r,
                                  foregroundImage: data
                                              .firstMutualConnectionPicture !=
                                          null
                                      ? NetworkImage(
                                          data.firstMutualConnectionPicture!)
                                      : AssetImage(
                                              'assets/images/default-profile-picture.png')
                                          as ImageProvider,
                                ),
                                Text(
                                  "${data.firstMutualConnectionName} and ${data.mutualConnectionsCount - 1} mutual connections",
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
                          child: IconButton(
                            onPressed: () {},
                            icon: Transform.rotate(
                              angle: -pi / 4, // 45 degrees counterclockwise
                              child: Icon(
                                Icons.send,
                                size: 22.r,
                                color: isDarkMode
                                    ? AppColors.darkTextColor
                                    : AppColors.lightTextColor,
                              ),
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

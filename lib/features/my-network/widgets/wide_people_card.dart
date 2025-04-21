import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class WidePeopleCard extends ConsumerWidget {
  final GrowTabPeopleCardsModel data;

  const WidePeopleCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.h,
        children: [
          Stack(
            clipBehavior: Clip.none, // Important to allow overflow
            alignment: Alignment.bottomLeft, // Align profile pic to bottom left
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                ),
                child: Image(
                  image: AssetImage(data.coverPicture),
                  width: double.infinity,
                  height: 65.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Profile image positioned to overlap
              Positioned(
                bottom: -25.h,
                left: 10.w,
                child: CircleAvatar(
                  radius: 40.r,
                  foregroundImage: AssetImage(data.profilePicture),
                ),
              ),
              // Follow Button
              Positioned(
                right: 7.w,
                bottom: -40.h,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 100.w,
                    maxHeight: 40.h,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: isDarkMode
                        ? LinkUpButtonStyles().myNetworkScreenConnectDark(
                            padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 5.h,
                          ))
                        : LinkUpButtonStyles().myNetworkScreenConnectLight(
                            padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 5.h,
                          )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20.w,
                          color: isDarkMode
                              ? AppColors.darkBlue
                              : AppColors.lightBlue,
                        ),
                        const Text(
                          "Follow",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Cancel Button
              Positioned(
                top: 5.h,
                right: 5.w,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: AppColors.fineLinesGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              "${data.firstName} ${data.lastName}",
              style: TextStyles.font15_700Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.lightTextColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              data.title,
              style: TextStyles.font12_400Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.lightTextColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            child: Row(
              spacing: 18.w,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    CircleAvatar(
                      radius: 12.r,
                      foregroundImage: AssetImage(data.profilePicture),
                    ),
                    Positioned(
                      left: 15.w,
                      child: CircleAvatar(
                        radius: 12.r,
                        foregroundImage: const AssetImage(
                            'assets/images/default-profile-picture.jpg'),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    "${data.firstMutualConnectionFirstName}, ${data.secondMutualConnectionFirstName} and ${data.mutualConnectionsNumber} others you know followed",
                    style: TextStyles.font13_400Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.lightSecondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

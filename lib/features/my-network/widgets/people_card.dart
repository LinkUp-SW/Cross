import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/model.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class PeopleCard extends ConsumerWidget {
  final GrowTabPeopleCardsModel data;
  final bool isDarkMode;
  const PeopleCard({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 170.w,
        maxHeight: 240.h,
      ),
      child: Card(
        shadowColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        elevation: 3.0.r,
        child: Column(
          spacing: 15.h,
          children: [
            Stack(
              clipBehavior: Clip.none, // Important to allow overflow
              alignment:
                  Alignment.bottomCenter, // Align profile pic to bottom center
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
                    height: 60.h,
                    fit: BoxFit.cover,
                  ),
                ),

                // Profile image - positioned to overlap
                Positioned(
                  bottom: -25.h,
                  right: 32.w,
                  child: CircleAvatar(
                    radius: 45.r,
                    backgroundImage: AssetImage(data.profilePicture),
                  ),
                ),
              ],
            ),
            const SizedBox(),
            Column(
              children: [
                Text(
                  "${data.firstName} ${data.lastName}",
                  style: TextStyles.font15_700Weight,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.0.w,
                  ),
                  child: Text(
                    data.title,
                    style: TextStyles.font15_500Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkGrey
                          : AppColors.lightSecondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                  ),
                  child: Row(
                    spacing: 5.w,
                    children: [
                      CircleAvatar(
                        radius: 10.r,
                        backgroundImage: AssetImage(
                            data.firstMutualConnectionProfilePicture),
                      ),
                      Flexible(
                        // Add Flexible to allow text to shrink
                        child: Text(
                          "${data.firstMutualConnectionFirstName} and ${data.mutualConnectionsNumber} other mutual connections",
                          style: TextStyles.font13_500Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkGrey
                                : AppColors.lightSecondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: isDarkMode
                        ? LinkUpButtonStyles().myNetworkScreenConnectDark()
                        : LinkUpButtonStyles().myNetworkScreenConnectLight(),
                    child: const Text("Connect"),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
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
                  image: NetworkImage(data.coverPicture),
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
                  foregroundImage: NetworkImage(data.profilePicture),
                ),
              ),
              // Cancel Button
              Positioned(
                top: 5.h,
                right: 3.w,
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
                      size: 20.h,
                    ),
                  ),
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
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        "Pressed on ${data.firstName} ${data.lastName} connect");
                  },
                  style: isDarkMode
                      ? LinkUpButtonStyles().myNetworkScreenConnectDark()
                      : LinkUpButtonStyles().myNetworkScreenConnectLight(),
                  child: const Text("Connect"),
                ),
              ),
            ],
          ),
          // Column(
          //   children: [
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 6.w,
          //   ),
          // child: Row(
          //   spacing: 5.w,
          //   children: [
          //     CircleAvatar(
          //       radius: 10.r,
          //       backgroundImage:
          //           AssetImage(data.firstMutualConnectionProfilePicture),
          //     ),
          //     Flexible(
          //       // Add Flexible to allow text to shrink
          //       child: Text(
          //         "${data.firstMutualConnectionFirstName} and ${data.mutualConnectionsNumber} other mutual connections",
          //         style: TextStyles.font13_500Weight.copyWith(
          //           color: isDarkMode
          //               ? AppColors.darkGrey
          //               : AppColors.lightSecondaryText,
          //         ),
          //         overflow: TextOverflow.ellipsis,
          //         maxLines: 2,
          //       ),
          //     )
          //   ],
          // ),
          // ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

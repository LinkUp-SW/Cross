import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/model/model.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class NewsletterCard extends ConsumerWidget {
  final GrowTabNewsletterCardsModel data;
  final bool isDarkMode;

  const NewsletterCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.h,
        children: [
          Stack(
            clipBehavior: Clip.none, // Important to allow overflow
            alignment: Alignment
                .bottomLeft, // Align newsletter profile pic to bottom left
            children: [
              // Newsletter cover image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                ),
                child: Image(
                  image: AssetImage(data.newsletterCoverPicture),
                  width: double.infinity,
                  height: 65.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Newsletter profile image positioned to overlap
              Positioned(
                bottom: -25.h,
                left: 10.w,
                child: Container(
                  width: 80.w,
                  height: 75.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.lightMain,
                      width: 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image(
                      image: AssetImage(
                        data.newsletterProfilePicture,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Subscribe Button
              Positioned(
                right: 7.w,
                bottom: -40.h,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 100.w,
                    maxHeight: 40.h,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      print("Pressed on ${data.newsletterName} Subscribe");
                    },
                    style: isDarkMode
                        ? LinkUpButtonStyles().myNetworkScreenConnectDark(
                            padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 5.h,
                          ))
                        : LinkUpButtonStyles().myNetworkScreenConnectLight(
                            padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 5.h,
                          )),
                    child: const Text(
                      "Subscribe",
                    ),
                  ),
                ),
              ),
              // Cancel Button
              Positioned(
                top: 5.h,
                right: 5.w,
                child: InkWell(
                  onTap: () {
                    print("Pressed on ${data.newsletterName} cancel");
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: AppColors.grey,
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
              data.newsletterName,
              style: TextStyles.font15_700Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.lightTextColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Row(
              spacing: 5.w,
              children: [
                Image(
                  image: AssetImage(data.companyPicture),
                  width: 20.w,
                  height: 20.h,
                ),
                Text(
                  data.companyName,
                  style: TextStyles.font12_400Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.newsletterDescription,
                  style: TextStyles.font13_400Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  "${parseIntegerToCommaSeparatedString(data.subscribersNumber)} subscribers",
                  style: TextStyles.font12_400Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

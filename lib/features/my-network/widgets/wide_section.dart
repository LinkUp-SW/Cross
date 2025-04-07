import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class WideSection extends ConsumerWidget {
  final String title;
  final List<Widget> cards;
  final bool isDarkMode;

  const WideSection({
    super.key,
    required this.title,
    required this.cards,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 5.h,
        ),
        child: Column(
          spacing: 5.h,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 5.w,
                ),
                child: Text(
                  title,
                  style: TextStyles.font15_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightTextColor,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
            ...cards.map(
              (card) => Row(
                children: [
                  Expanded(child: card),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "Show all",
                style: TextStyles.font15_700Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.lightSecondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

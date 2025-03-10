import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class Section extends ConsumerWidget {
  final String title;
  final List<PeopleCard> cards;
  final bool isDarkMode;

  const Section(
      {super.key,
      required this.title,
      required this.cards,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create rows of cards (2 cards per row)
    List<Widget> cardRows = [];

    for (int i = 0; i < cards.length; i += 2) {
      List<Widget> rowCards = [];

      // First card
      rowCards.add(Expanded(child: cards[i]));

      // Second card
      rowCards.add(Expanded(child: cards[i + 1]));

      // Add the row
      cardRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowCards,
        ),
      );
    }
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
            ...cardRows,
            InkWell(
              onTap: () {
                print("Pressed on $title Show all");
              },
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

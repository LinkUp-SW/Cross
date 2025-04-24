import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class Section extends ConsumerWidget {
  final String title;
  final List<PeopleCard> cards;

  const Section({
    super.key,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Create rows of cards (2 cards per row)
    List<Widget> cardRows = [];

    for (int i = 0; i < cards.length; i += 2) {
      // If this is the last card and it's an odd count
      if (i + 1 == cards.length) {
        // Add a centered single card row
        cardRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[i]),
              Expanded(child: SizedBox()),
            ],
          ),
        );
      } else {
        // Regular row with two cards
        cardRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[i]),
              Expanded(child: cards[i + 1]),
            ],
          ),
        );
      }
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
          ],
        ),
      ),
    );
  }
}

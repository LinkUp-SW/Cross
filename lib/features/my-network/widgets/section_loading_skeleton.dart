import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/widgets/people_card_loading_skeleton.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SectionLoadingSkeleton extends ConsumerWidget {
  final String title;

  const SectionLoadingSkeleton({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Skeletonizer(
      child: Material(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          child: Column(
            spacing: 5,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 5,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GrowTabPeopleCardLoadingSkeleton(),
                  ),
                  Expanded(
                    child: GrowTabPeopleCardLoadingSkeleton(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GrowTabPeopleCardLoadingSkeleton(),
                  ),
                  Expanded(
                    child: GrowTabPeopleCardLoadingSkeleton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class ConfirmationPopUp extends ConsumerWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback buttonFunctionality;

  const ConfirmationPopUp({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    required this.buttonFunctionality,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              title,
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
            Text(
              content,
              style: TextStyles.font16_500Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 15,
              children: [
                Material(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: TextStyles.font16_500Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  child: InkWell(
                    onTap: buttonFunctionality,
                    child: Text(
                      buttonText,
                      style: TextStyles.font16_500Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

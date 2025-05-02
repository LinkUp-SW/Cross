import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class EmailConfirmationPopUp extends ConsumerStatefulWidget {
  final VoidCallback buttonFunctionality;

  const EmailConfirmationPopUp({
    super.key,
    required this.buttonFunctionality,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EmailConfirmationPopUpState();
}

class _EmailConfirmationPopUpState
    extends ConsumerState<EmailConfirmationPopUp> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.h,
          children: [
            Text(
              "Please enter this user personal email",
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
            TextField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 15.w,
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
                    onTap: widget.buttonFunctionality,
                    child: Text(
                      "Send",
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

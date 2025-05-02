import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/search/viewModel/email_confirmation_pop_up_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:go_router/go_router.dart';

class EmailConfirmationPopUp extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onConnectionRequestSent;
  const EmailConfirmationPopUp({
    super.key,
    required this.userId,
    this.onConnectionRequestSent,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EmailConfirmationPopUpState();
}

class _EmailConfirmationPopUpState
    extends ConsumerState<EmailConfirmationPopUp> {
  final TextEditingController _emailController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(emailConfirmationPopUpViewModelProvider);
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
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: TextStyles.font14_500Weight.copyWith(
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
                errorText: state.errorMessage,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color:
                        isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                    width: 2.w,
                  ),
                ),
              ),
              onChanged: (_) async => await ref
                  .read(emailConfirmationPopUpViewModelProvider.notifier)
                  .clearErrorMessage(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 15.w,
              children: [
                Material(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  child: InkWell(
                    onTap: () => context.pop(),
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
                    onTap: () async {
                      await ref
                          .read(
                              emailConfirmationPopUpViewModelProvider.notifier)
                          .validateEmail(_emailController.text.trim());
                      final updatedState =
                          ref.read(emailConfirmationPopUpViewModelProvider);
                      if (!updatedState.isError) {
                        await ref
                            .read(emailConfirmationPopUpViewModelProvider
                                .notifier)
                            .sendConnectionRequest(
                          widget.userId,
                          body: {
                            "email": _emailController.text.trim(),
                          },
                        );

                        if (!context.mounted) return;

                        final finalState =
                            ref.read(emailConfirmationPopUpViewModelProvider);

                        if (!finalState.isError &&
                            widget.onConnectionRequestSent != null) {
                          widget.onConnectionRequestSent!();
                        }
                        context.pop();
                      }
                    },
                    child: state.isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 3.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode
                                  ? AppColors.darkBlue
                                  : AppColors.lightBlue,
                            ),
                          )
                        : Text(
                            "Send",
                            style: TextStyles.font16_500Weight.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkBlue
                                  : AppColors.lightBlue,
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

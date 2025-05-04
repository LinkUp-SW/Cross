// lib/features/profile/view/edit_about_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/state/edit_about_state.dart';
import 'package:link_up/features/profile/viewModel/edit_about_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'dart:developer'; // Import log

class EditAboutPage extends ConsumerStatefulWidget {
  const EditAboutPage({super.key});

  @override
  ConsumerState<EditAboutPage> createState() => _EditAboutPageState();
}

class _EditAboutPageState extends ConsumerState<EditAboutPage> {
  final FocusNode _aboutFocusNode = FocusNode();

  @override
  void dispose() {
    _aboutFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(editAboutViewModelProvider);
    final viewModel = ref.read(editAboutViewModelProvider.notifier);

    // Listen for success state to navigate back
    ref.listen<EditAboutState>(editAboutViewModelProvider, (previous, next) {
      if (next is EditAboutSuccess) {
        if (mounted) {
          GoRouter.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('About section saved!'), backgroundColor: Colors.green),
          );
        }
      } else if (next is EditAboutError) {
         if (mounted && (previous is! EditAboutError || previous.message != next.message)) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error: ${next.message}'), backgroundColor: Colors.red),
             );
         }
      }
    });

    bool isLoading = state is EditAboutLoading || state is EditAboutInitial;
    bool isSaving = state is EditAboutSaving;
    int currentCharCount = viewModel.aboutController.text.length;
    int maxChars = viewModel.maxAboutChars;

    // Handle case where initial load failed but user might still have text
    String? errorDisplayText;
    if (state is EditAboutError) {
       errorDisplayText = state.previousAboutText;
       if (errorDisplayText != null && viewModel.aboutController.text != errorDisplayText) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
                viewModel.aboutController.text = errorDisplayText!;
                viewModel.aboutController.selection = TextSelection.fromPosition(
                   TextPosition(offset: viewModel.aboutController.text.length),
                );
                // Manually trigger state update for character count
                setState(() {});
             }
          });
       }
    }

    log("[EditAboutPage] Build triggered. State: $state, isLoading: $isLoading, isSaving: $isSaving");

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Edit about",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is EditAboutError && state.previousAboutText == null // Handle initial load error specifically
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text("Error loading data: ${state.message}", style: TextStyle(color: Colors.red)),
                            )
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "You can write about your years of experience, industry, or skills. People also talk about their achievements or previous job experiences.",
                                  style: TextStyles.font14_400Weight.copyWith(
                                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                TextField(
                                  controller: viewModel.aboutController,
                                  focusNode: _aboutFocusNode,
                                  enabled: !isSaving,
                                  maxLines: 10,
                                  minLines: 5,
                                  maxLength: maxChars,
                                  style: TextStyles.font14_400Weight.copyWith(
                                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                  ),
                                  cursorColor: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                                  decoration: InputDecoration(
                                    hintText: "Start writing your about section...",
                                    hintStyle: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.lightGrey),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.lightGrey),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
                                    ),
                                    counterText: "", // Hide default counter
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                  ),
                                  onChanged: (value) {
                                     // Trigger rebuild to update character count display
                                     setState(() {});
                                  },
                                ),
                                // Custom Character Count Display
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h, right: 4.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "$currentCharCount / $maxChars",
                                        style: TextStyles.font12_400Weight.copyWith(
                                          color: currentCharCount > maxChars
                                              ? Colors.red // Highlight if over limit
                                              : AppColors.lightGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15.h),

                                
            // Save Button Footer
            if (!isLoading)
              Container(
                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                 color: isDarkMode ? AppColors.darkMain : AppColors.lightMain, // Match background
                 child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: isSaving || (currentCharCount > maxChars) // Disable if saving or over limit
                         ? null
                         : () => viewModel.saveAbout(),
                     style: (isDarkMode
                           ? buttonStyles.wideBlueElevatedButtonDark()
                           : buttonStyles.wideBlueElevatedButton()
                     ).copyWith(
                         minimumSize: MaterialStateProperty.all(Size.fromHeight(50.h)),
                         // Grey out button if disabled
                         backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                           (Set<MaterialState> states) {
                             if (states.contains(MaterialState.disabled)) {
                               return AppColors.lightGrey.withOpacity(0.5);
                             }
                             return isDarkMode ? AppColors.darkBlue : AppColors.lightBlue; // Default color
                           },
                         ),
                     ),
                     child: isSaving
                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.lightMain, strokeWidth: 2.0))
                         : Text(
                             "Save",
                             style: TextStyles.font15_500Weight.copyWith(
                               color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                             ),
                           ),
                   ),
                 ),
               ),
          ],
        ),
      ),
    ))])));
  }
}

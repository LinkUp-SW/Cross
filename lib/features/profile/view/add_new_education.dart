import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/features/profile/widgets/subpages_section_headers.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';

class AddNewEducation extends ConsumerWidget {
  const AddNewEducation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    // Controllers for text fields
    final schoolController = TextEditingController();
    final degreeController = TextEditingController();
    final fieldOfStudyController = TextEditingController();
    final endDateController = TextEditingController(text: "Present");
    final startDateController = TextEditingController();
    final activitiesAndSocietiesController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Add new position",
              onClosePressed: () {
                GoRouter.of(context).pop();
              },
            ),
            Expanded(
              child: Container(
                color: AppColors.lightMain,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SubPagesIndicatesRequiredLabel(),
                      SizedBox(height: 10.h),
                      SubPagesFormLabel(label: "School", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: schoolController,
                        hintText: "Ex: Cairo University",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Degree", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: degreeController,
                        hintText: "Ex: Bachelor's",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Field of Study", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: fieldOfStudyController,
                        hintText: "Ex: Engineering",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Start date", isRequired: true),
                      SubPagesCustomTextField(
                        controller: startDateController,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 15.sp,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "End date or expected",
                          isRequired: true),
                      SubPagesCustomTextField(
                        controller: endDateController,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 15.sp,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Activities and Societies"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: activitiesAndSocietiesController,
                        hintText: "Ex: IEEE",
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "0/500",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Description"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: descriptionController,
                        hintText: "List your major duties and successes",
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "0/1000",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SubPagesSectionHeader(title: "Skills"),
                      SizedBox(height: 10.h),
                      Text(
                        "We recommend adding your top 5 used in this role. They'll also appear in your Skills section.",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () {
                          // Handle add skill
                        },
                        style: isDarkMode
                            ? buttonStyles.blueOutlinedButtonDark()
                            : buttonStyles.blueOutlinedButton(),
                        child: Text(
                          "+ Add skill",
                          style: TextStyles.font14_600Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkBlue
                                : AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SubPagesSectionHeader(title: "Media"),
                      SizedBox(height: 10.h),
                      Text(
                        "Add media like images or sites. Learn more about media file types supported",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () {
                          // Handle add media
                        },
                        style: isDarkMode
                            ? buttonStyles.blueOutlinedButtonDark()
                            : buttonStyles.blueOutlinedButton(),
                        child: Text(
                          "+ Add media",
                          style: TextStyles.font14_600Weight.copyWith(
                            color: isDarkMode
                                ? AppColors.darkBlue
                                : AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save action
                    GoRouter.of(context).pop();
                  },
                  style: buttonStyles.wideBlueElevatedButton(),
                  child: Text(
                    "Save",
                    style: TextStyles.font15_500Weight.copyWith(
                      color: AppColors.lightMain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
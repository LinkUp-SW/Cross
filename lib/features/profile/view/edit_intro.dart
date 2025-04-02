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


class EditIntroPage extends ConsumerWidget {
  const EditIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    final firstNameController = TextEditingController(text: "Amr");
    final lastNameController = TextEditingController(text: "Safwat");
    final additionalNameController = TextEditingController();
    final headlineController =
        TextEditingController(text: "Student at Cairo University");
    final industryController = TextEditingController(text: "Retail");
    final schoolController = TextEditingController(text: "Cairo University");
    final countryController = TextEditingController(text: "Egypt");
    final cityController = TextEditingController(text: "Giza, Al Jizah");

    bool showSchoolInIntro = false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Edit intro",
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
                      SubPagesFormLabel(label: "First Name*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: firstNameController,
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Family Name*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: lastNameController,
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Additional Name*"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: additionalNameController,
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Headline*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: headlineController,
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push('/add_new_position');
                        },
                        child: Text(
                          "+ Add new position",
                          style: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Industry*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: industryController,
                        hintText: "Ex: Retail",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesSectionHeader(title: "Education"),
                      SizedBox(height: 10.h),
                      SubPagesFormLabel(label: "School*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: schoolController,
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push('/add_new_education');
                        },
                        child: Text(
                          "+ Add new education",
                          style: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Checkbox(
                            value: showSchoolInIntro,
                            onChanged: (value) {},
                            activeColor: AppColors.lightGreen,
                          ),
                          Text(
                            "Show school in my intro",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SubPagesSectionHeader(title: "Location"),
                      SizedBox(height: 10.h),
                      SubPagesFormLabel(label: "Country/Region*", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: countryController,
                        suffixIcon: Icon(
                          Icons.close,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Use current location",
                          style: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "City"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: cityController,
                        suffixIcon: Icon(
                          Icons.close,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SubPagesSectionHeader(title: "Contact info"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add or edit your profile URL, email, and more",
                              style: TextStyles.font14_400Weight.copyWith(
                                color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightTextColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            GestureDetector(
                              onTap: () {
                                GoRouter.of(context).push('/edit_contact_info');
                              },
                              child: Text(
                                "Edit contact info",
                                style: TextStyles.font14_400Weight.copyWith(
                                  color: AppColors.lightBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
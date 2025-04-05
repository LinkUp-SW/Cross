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
import 'package:link_up/features/profile/widgets/subpages_dropdown.dart';

class AddNewPosition extends ConsumerWidget {
  const AddNewPosition({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    // Controllers for text fields
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController(text: "Present");
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final profileHeadlineController =
        TextEditingController(text: "Student at Cairo University");

    // State for checkbox
    bool isCurrentlyWorking = true;

    // State for dropdowns
    String? selectedEmploymentType;
    String? selectedLocationType;

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
                      SubPagesFormLabel(label: "Title", isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: titleController,
                        hintText: "Ex: Retail Sales Manager",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Employment type"),
                      SizedBox(height: 2.h),
                      SubPagesCustomDropdownFormField<String>(
                        value: selectedEmploymentType,
                        hintText: "Please select",
                        items: [
                          DropdownMenuItem(
                              value: "Full-time", child: Text("Full-time")),
                          DropdownMenuItem(
                              value: "Part-time", child: Text("Part-time")),
                          DropdownMenuItem(
                              value: "Contract", child: Text("Contract")),
                          DropdownMenuItem(
                              value: "Freelance", child: Text("Freelance")),
                        ],
                        onChanged: (value) {
                          selectedEmploymentType = value;
                        },
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Company or organization*",
                          isRequired: true),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: companyController,
                        hintText: "Ex: Microsoft",
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Checkbox(
                            value: isCurrentlyWorking,
                            onChanged: (value) {},
                            activeColor: Colors.green,
                          ),
                          Text(
                            "I am currently working in this role",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightTextColor,
                            ),
                          ),
                        ],
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
                      SubPagesFormLabel(label: "End date", isRequired: true),
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
                      SubPagesFormLabel(label: "Location"),
                      SubPagesCustomTextField(
                        controller: locationController,
                        hintText: "Ex: London, United Kingdom",
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Location type"),
                      SizedBox(height: 2.h),
                      SubPagesCustomDropdownFormField<String>(
                        value: selectedLocationType,
                        hintText: "Please select",
                        items: [
                          DropdownMenuItem(
                              value: "On-site", child: Text("On-site")),
                          DropdownMenuItem(
                              value: "Remote", child: Text("Remote")),
                          DropdownMenuItem(
                              value: "Hybrid", child: Text("Hybrid")),
                        ],
                        onChanged: (value) {
                          selectedLocationType = value;
                        },
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
                            "0/2000",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SubPagesFormLabel(label: "Profile headline"),
                      SubPagesCustomTextField(
                        controller: profileHeadlineController,
                        hintText: "Student at Cairo University",
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Appears below your name at the top of the profile",
                        style: TextStyles.font13_400Weight.copyWith(
                          color: AppColors.lightGrey,
                        ),
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
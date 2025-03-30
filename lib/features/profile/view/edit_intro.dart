import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:go_router/go_router.dart';

class EditIntroPage extends ConsumerWidget {
  const EditIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    final firstNameController = TextEditingController(text: "Amr");
    final lastNameController = TextEditingController(text: "Safwat");
    final additionalNameController = TextEditingController();
    final headlineController = TextEditingController(text: "Student at Cairo University");
    final industryController = TextEditingController(text: "Retail");
    final schoolController = TextEditingController(text: "Cairo University");
    final countryController = TextEditingController(text: "Egypt");
    final cityController = TextEditingController(text: "Giza, Al Jizah");

    bool showSchoolInIntro = true;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                  ),
                  Text(
                    "Edit intro",
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.lightMain,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "* Indicates required",
                        style: TextStyles.font13_400Weight.copyWith(
                          color: AppColors.lightGrey,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "First Name*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: firstNameController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground, // Set cursor color to black
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Family Name*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: lastNameController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Additional Name*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: additionalNameController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Headline*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: headlineController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {GoRouter.of(context).push('/add_new_position');

                        },
                        child: Text(
                          "+ Add new position",
                          style: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Industry*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: industryController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          hintText: "Ex: Retail",
                          hintStyle: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightGrey,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                  
                      SizedBox(height: 20.h),
                      Text(
                        "Education",
                        style: TextStyles.font18_700Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "School*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: schoolController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {GoRouter.of(context).push('/add_new_education');
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
                            onChanged: (value) {
                            },
                            activeColor: Colors.green,
                          ),
                          Text(
                            "Show school in my intro",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Location",
                        style: TextStyles.font18_700Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Country/Region*",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: countryController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.close,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                            size: 20.sp,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                        },
                        child: Text(
                          "Use current location",
                          style: TextStyles.font14_400Weight.copyWith(
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "City",
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: cityController,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                        cursorColor: AppColors.darkBackground,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.close,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                            size: 20.sp,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Contact info",
                        style: TextStyles.font18_700Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add or edit your profile URL, email, and more",
                              style: TextStyles.font14_400Weight.copyWith(
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
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
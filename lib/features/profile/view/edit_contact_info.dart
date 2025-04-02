import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/features/profile/widgets/subpages_dropdown.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';

// Providers for state management
final phoneTypeProvider = StateProvider<String?>((ref) => null);
final addressLengthProvider = StateProvider<int>((ref) => 0);

class EditContactInfo extends ConsumerWidget {
  const EditContactInfo({Key? key}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Copied!",
          style: TextStyles.font14_400Weight.copyWith(
            color: AppColors.lightMain,
          ),
        ),
        backgroundColor: AppColors.lightBlue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    // Controllers for text fields
    final phoneNumberController = TextEditingController();
    final addressController = TextEditingController();
    final birthdayController = TextEditingController();
    final websiteController = TextEditingController();

    // Predefined values for Profile URL and Email (not editable)
    const profileUrl = "https://www.linkedin.com/in/amr-safwat-433536357";
    const email = "amrosafwat23@hotmail.com";

    // Update character counter for address
    addressController.addListener(() {
      ref.read(addressLengthProvider.notifier).state =
          addressController.text.length;
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            SubPagesAppBar(
              title: "Edit contact info",
              onClosePressed: () {
                GoRouter.of(context).pop();
              },
            ),
            // Scrollable content
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
                      // Profile URL (non-editable link)
                      SubPagesFormLabel(label: "Profile URL"),
                      SizedBox(height: 2.h),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, profileUrl),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                profileUrl,
                                style: TextStyles.font14_400Weight.copyWith(
                                  color: AppColors.lightBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: AppColors.lightBlue,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Email (non-editable link)
                      SubPagesFormLabel(label: "Email"),
                      SizedBox(height: 2.h),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, email),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                email,
                                style: TextStyles.font14_400Weight.copyWith(
                                  color: AppColors.lightBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: AppColors.lightBlue,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Phone number
                      SubPagesFormLabel(label: "Phone number"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: phoneNumberController,
                      ),
                      SizedBox(height: 20.h),
                      // Phone type
                      SubPagesFormLabel(label: "Phone type"),
                      SizedBox(height: 2.h),
                      SubPagesCustomDropdownFormField<String>(
                        value: ref.watch(phoneTypeProvider),
                        hintText: "Please select",
                        
                        items: [
                          DropdownMenuItem(
                              value: "Mobile", child: Text("Mobile")),
                          DropdownMenuItem(value: "Home", child: Text("Home")),
                          DropdownMenuItem(value: "Work", child: Text("Work")),
                        ],
                        onChanged: (value) {
                          ref.read(phoneTypeProvider.notifier).state = value;
                        },
                      ),
                      SizedBox(height: 20.h),
                      // Address
                      SubPagesFormLabel(label: "Address"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: addressController,
                        maxLines: 3,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${ref.watch(addressLengthProvider)}/220",
                            style: TextStyles.font14_400Weight.copyWith(
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Birthday
                      SubPagesFormLabel(label: "Birthday"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: birthdayController,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                          size: 20.sp,
                        ),
                        onTap: () {
                          // Handle date picker
                        },
                      ),
                      SizedBox(height: 20.h),
                      // Website
                      SubPagesFormLabel(label: "Website"),
                      SizedBox(height: 2.h),
                      SubPagesCustomTextField(
                        controller: websiteController,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            // Save button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  style: isDarkMode
                      ? buttonStyles.wideBlueElevatedButtonDark()
                      : buttonStyles.wideBlueElevatedButton(),
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
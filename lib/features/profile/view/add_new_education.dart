import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/state/add_education_state.dart';
import 'package:link_up/features/profile/viewModel/add_education_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';
import 'package:link_up/features/profile/widgets/subpages_section_headers.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class AddNewEducation extends ConsumerStatefulWidget {
  const AddNewEducation({super.key});

  @override
  ConsumerState<AddNewEducation> createState() => _AddNewEducationState();
}

class _AddNewEducationState extends ConsumerState<AddNewEducation> {
  final FocusNode _startDateFocusNode = FocusNode();
  final FocusNode _endDateFocusNode = FocusNode();
  int _currentWordCount = 0; 

  // Word count limit (should match ViewModel)
  final int maxWordCount = 200;

  // Function to count words (simple space split)
  int _countWords(String text) {
    text = text.trim();
    if (text.isEmpty) {
      return 0;
    }
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
    // Add listener AFTER the first build when controllers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the provider is initialized before accessing state
      if (!mounted) return;
      final state = ref.read(addEducationViewModelProvider);
      final formData = (state is AddEducationIdle)
          ? state.formData
          : (state is AddEducationFailure)
              ? state.formData
              : null;

      if (formData != null) {
        // Initialize word count
        _currentWordCount = _countWords(formData.descriptionController.text);
        // Add listener to description controller
        formData.descriptionController.addListener(_updateWordCount);
      }
    });
  }

  void _updateWordCount() {
     if (mounted) { // Check if the state is still mounted
       final state = ref.read(addEducationViewModelProvider);
       final formData = (state is AddEducationIdle)
            ? state.formData
            : (state is AddEducationFailure)
                ? state.formData
                : null;
        if(formData != null){
          setState(() {
            _currentWordCount = _countWords(formData.descriptionController.text);
          });
        }
     }
  }


  @override
  void dispose() {
    // Remove listener when the widget is disposed
    // Accessing controllers safely requires checking the state type again
    final state = ref.read(addEducationViewModelProvider);
     final formData = (state is AddEducationIdle)
          ? state.formData
          : (state is AddEducationFailure)
              ? state.formData
              : null;
     if (formData != null) {
        formData.descriptionController.removeListener(_updateWordCount);
     }

    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
     final viewModel = ref.read(addEducationViewModelProvider.notifier);
     final currentState = viewModel.state; // Read current state directly
     final currentFormData = (currentState is AddEducationIdle)
        ? currentState.formData
        : (currentState is AddEducationFailure)
          ? currentState.formData
          : null;

     if (currentFormData == null) return;

     if (!isStartDate && currentFormData.isEndDatePresent) return;

     final initialDate = isStartDate
         ? currentFormData.selectedStartDate ?? DateTime.now()
         : currentFormData.selectedEndDate ?? currentFormData.selectedStartDate ?? DateTime.now();
     final firstDate = DateTime(1900);
     final lastDate = DateTime.now().add(const Duration(days: 365 * 10));

     final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      viewModel.setDate(picked, isStartDate);
    }

     if (isStartDate) {
       _startDateFocusNode.unfocus();
     } else {
       _endDateFocusNode.unfocus();
     }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    ref.listen<AddEducationFormState>(addEducationViewModelProvider, (previous, next) {
      if (next is AddEducationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education saved successfully!')),
        );
        GoRouter.of(context).pop();
      } else if (next is AddEducationFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.message}')),
        );
      }
    });

    final state = ref.watch(addEducationViewModelProvider);
    final viewModel = ref.read(addEducationViewModelProvider.notifier);

    final formData = (state is AddEducationIdle)
        ? state.formData
        : (state is AddEducationLoading)
            ? state.formData
            : (state is AddEducationFailure)
                ? state.formData
                : null;

    return Scaffold(
        backgroundColor: AppColors.lightMain,
        body: SafeArea(
          child: Column(
            children: [
              SubPagesAppBar(
                title: "Add education",
                onClosePressed: () {
                  GoRouter.of(context).pop();
                },
              ),
              Expanded(
                child: Container(
                  color: AppColors.lightMain,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: formData == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SubPagesIndicatesRequiredLabel(),
                              SizedBox(height: 10.h),
                              SubPagesFormLabel(label: "School", isRequired: true),
                              SizedBox(height: 2.h),
                              SubPagesCustomTextField(
                                controller: formData.schoolController,
                                hintText: "Ex: Cairo University",
                              ),
                              SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Degree", isRequired: true),
                              SizedBox(height: 2.h),
                              SubPagesCustomTextField(
                                controller: formData.degreeController,
                                hintText: "Ex: Bachelor's",
                              ),
                              SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Field of Study", isRequired: true),
                              SizedBox(height: 2.h),
                              SubPagesCustomTextField(
                                controller: formData.fieldOfStudyController,
                                hintText: "Ex: Engineering",
                              ),
                              SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Start date", isRequired: true),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: AbsorbPointer(
                                  child: SubPagesCustomTextField(
                                    controller: formData.startDateController,
                                    hintText: "Select start date",
                                    focusNode: _startDateFocusNode,
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                      size: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "End date or expected", isRequired: true),
                               InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: AbsorbPointer(
                                     child: SubPagesCustomTextField(
                                       controller: formData.endDateController,
                                       hintText: formData.isEndDatePresent ? "Present" : "Select end date",
                                       focusNode: _endDateFocusNode,
                                       enabled: !formData.isEndDatePresent,
                                       suffixIcon: Icon(
                                          Icons.calendar_today,
                                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                          size: 15.sp,
                                       ),
                                     ),
                                  ),
                               ),
                               Row(
                                  children: [
                                     Checkbox(
                                        value: formData.isEndDatePresent,
                                        onChanged: (value) {
                                           if (value != null) {
                                              viewModel.setIsEndDatePresent(value);
                                           }
                                        },
                                        activeColor: AppColors.lightGreen,
                                     ),
                                     Text(
                                        "I am currently studying here",
                                        style: TextStyles.font14_400Weight.copyWith(
                                           color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                        ),
                                     ),
                                  ],
                                ),
                               SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Grade"),
                               SizedBox(height: 2.h),
                               SubPagesCustomTextField(
                                  controller: formData.gradeController,
                                  hintText: "Ex: 3.8/4.0 or 85%",
                               ),
                               SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Activities and Societies"),
                              SizedBox(height: 2.h),
                              SubPagesCustomTextField(
                                controller: formData.activitiesController,
                                hintText: "Ex: IEEE, Debate Club",
                                maxLines: 3,
                              ),
                              SizedBox(height: 20.h),
                              SubPagesFormLabel(label: "Description"),
                              SizedBox(height: 2.h),
                              SubPagesCustomTextField(
                                controller: formData.descriptionController,
                                hintText: "Add details about your education...",
                                 maxLines: null, // Changed to null
                              ),
                              // Word Counter Feedback
                              Padding(
                                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$_currentWordCount / $maxWordCount words",
                                      style: TextStyles.font12_400Weight.copyWith(
                                        color: _currentWordCount > maxWordCount
                                               ? Colors.red // Highlight if over limit
                                               : AppColors.lightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Skills and Media sections remain UI only for now
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
                                  print("Add Skill tapped - No action implemented");
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
                                  print("Add Media tapped - No action implemented");
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
                    onPressed: state is AddEducationLoading
                        ? null
                        : () {
                            viewModel.saveEducation();
                          },
                    style: buttonStyles.wideBlueElevatedButton(),
                    child: state is AddEducationLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)
                        : Text(
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
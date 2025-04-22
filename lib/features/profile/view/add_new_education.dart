import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

import 'package:link_up/shared/widgets/autocomplete_search_input.dart';
import 'package:link_up/features/signUp/viewModel/past_job_details_provider.dart';


class AddNewEducation extends ConsumerStatefulWidget {
  const AddNewEducation({super.key});

  @override
  ConsumerState<AddNewEducation> createState() => _AddNewEducationState();
}

class _AddNewEducationState extends ConsumerState<AddNewEducation> {
  final FocusNode _startDateFocusNode = FocusNode();
  final FocusNode _endDateFocusNode = FocusNode();
  final FocusNode _schoolFocusNode = FocusNode();

  int _descriptionCharCount = 0;
  final int _maxDescriptionChars = 2000;

  int _activitiesCharCount = 0;
  final int _maxActivitiesChars = 500;

  Map<String, dynamic>? _selectedSchoolData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentViewModelState = ref.read(addEducationViewModelProvider);
      final formData = _getFormDataFromState(currentViewModelState);

      if (formData != null) {
        formData.descriptionController.addListener(_updateDescriptionCharCount);
        formData.activitiesController.addListener(_updateActivitiesCharCount);
        _updateDescriptionCharCount();
        _updateActivitiesCharCount();
      }
    });
  }

  AddEducationFormData? _getFormDataFromState(AddEducationFormState state) {
    if (state is AddEducationIdle) {
      return state.formData;
    } else if (state is AddEducationLoading) {
      return state.formData;
    } else if (state is AddEducationFailure) {
      return state.formData;
    }
    return null;
  }

  void _updateDescriptionCharCount() {
    final formData = _getFormDataFromState(ref.read(addEducationViewModelProvider));
    if (mounted && formData != null) {
      final currentCount = formData.descriptionController.text.length;
      if (_descriptionCharCount != currentCount) {
        setState(() {
          _descriptionCharCount = currentCount;
        });
      }
    }
  }

  void _updateActivitiesCharCount() {
    final formData = _getFormDataFromState(ref.read(addEducationViewModelProvider));
    if (mounted && formData != null) {
       final currentCount = formData.activitiesController.text.length;
       if (_activitiesCharCount != currentCount) {
         setState(() {
           _activitiesCharCount = currentCount;
         });
       }
    }
  }

  @override
  void dispose() {
     final formData = _getFormDataFromState(ref.read(addEducationViewModelProvider));
     if (formData != null) {
        formData.descriptionController.removeListener(_updateDescriptionCharCount);
        formData.activitiesController.removeListener(_updateActivitiesCharCount);
     }

    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    _schoolFocusNode.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _searchSchoolsProfile(String query) async {
    final notifier = ref.read(pastJobDetailProvider.notifier);
    await notifier.getSchools(query, ref);
    return ref.read(schoolResultsProvider);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final viewModel = ref.read(addEducationViewModelProvider.notifier);
    final currentState = viewModel.state;
    final currentFormData = _getFormDataFromState(currentState);

    if (currentFormData == null) return;
    if (!isStartDate && currentFormData.isEndDatePresent) return;

    final initialDate = isStartDate
        ? currentFormData.selectedStartDate ?? DateTime.now()
        : currentFormData.selectedEndDate ??
            currentFormData.selectedStartDate ??
            DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now().add(const Duration(days: 365 * 10)); 

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
       builder: (context, child) {
         final isDarkMode = Theme.of(context).brightness == Brightness.dark;
         return Theme(
           data: ThemeData(
             colorScheme: isDarkMode ? const ColorScheme.dark(
                 primary: AppColors.darkBlue,
                 onPrimary: AppColors.darkMain,
                 surface: AppColors.darkMain,
                 onSurface: AppColors.darkTextColor,
             ) : const ColorScheme.light(
                 primary: AppColors.lightBlue,
                 onPrimary: AppColors.lightMain,
                 surface: AppColors.lightMain,
                 onSurface: AppColors.lightTextColor,
             ),
              dialogBackgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
           ),
           child: child!,
         );
       },
    );

    if (picked != null) viewModel.setDate(picked, isStartDate);


  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();

    ref.listen<AddEducationFormState>(addEducationViewModelProvider,
        (previous, next) {

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
    final formData = _getFormDataFromState(state);


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Add education",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                 color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: formData == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SubPagesIndicatesRequiredLabel(),
                            SizedBox(height: 10.h),
                            SubPagesFormLabel(
                                label: "School", isRequired: true),
                            SizedBox(height: 2.h),

                            AutocompleteSearchInput(
                                controller: formData.schoolController,
                                label: "Ex: Cairo University", 
                                searchFunction: _searchSchoolsProfile, 
                                onSelected: (selectedItem) {
                                  
                                   setState(() {
                                      _selectedSchoolData = selectedItem;
                                   });
                                    print("Selected School (Profile): $selectedItem");
                                },
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(
                                label: "Degree", isRequired: true),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.degreeController,
                              hintText: "Ex: Bachelor's",
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(
                                label: "Field of Study", isRequired: true),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.fieldOfStudyController,
                              hintText: "Ex: Engineering",
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(
                                label: "Start date", isRequired: true),
                            InkWell( 
                              onTap: () => _selectDate(context, true),
                              child: AbsorbPointer( 
                                child: SubPagesCustomTextField(
                                  controller: formData.startDateController,
                                  hintText: "Select start date",
                                  focusNode: _startDateFocusNode,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: isDarkMode
                                        ? AppColors.darkTextColor
                                        : AppColors.lightTextColor,
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(
                                label: "End date or expected",
                                isRequired: true),
                            InkWell( 
                              onTap: formData.isEndDatePresent
                                  ? null 
                                  : () => _selectDate(context, false),
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.endDateController,
                                  hintText: formData.isEndDatePresent
                                      ? "Present"
                                      : "Select end date",
                                  focusNode: _endDateFocusNode,
                                  enabled: !formData.isEndDatePresent,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: formData.isEndDatePresent
                                          ? AppColors.lightGrey 
                                          : (isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
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

                                       if (!value && formData.endDateController.text == "Present") {
                                          formData.endDateController.clear(); 
                              
                                          if (formData.selectedEndDate != null) {
                                             viewModel.setDate(formData.selectedEndDate!, false);
                                          }
                                       }
                                    }
                                  },
                                  activeColor: AppColors.lightGreen,
                                ),
                                Text(
                                  "I am currently studying here",
                                  style: TextStyles.font14_400Weight.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextColor
                                        : AppColors.lightTextColor,
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
                            SubPagesFormLabel(
                                label: "Activities and Societies"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.activitiesController,
                              hintText: "Ex: IEEE, Debate Club",
                              maxLines: null, 
                            ),
                             Padding(
                              padding: EdgeInsets.only(top: 4.h, right: 8.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "$_activitiesCharCount / $_maxActivitiesChars characters",
                                    style: TextStyles.font12_400Weight.copyWith(
                                      color: _activitiesCharCount > _maxActivitiesChars
                                             ? Colors.red
                                             : AppColors.lightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Description"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.descriptionController,
                              hintText: "Add details about your education...",
                              maxLines: null,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, right: 8.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "$_descriptionCharCount / $_maxDescriptionChars characters",
                                    style: TextStyles.font12_400Weight.copyWith(
                                      color: _descriptionCharCount > _maxDescriptionChars
                                             ? Colors.red
                                             : AppColors.lightGrey,
                                    ),
                                  ),
                                ],
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
                                 // TODO: Implement Add Skill functionality
                                },
                              style: isDarkMode
                                  ? buttonStyles.blueOutlinedButtonDark()
                                  : buttonStyles.blueOutlinedButton(),
                              child: Text("+ Add skill",
                                  style: TextStyles.font14_600Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkBlue
                                          : AppColors.lightBlue)),
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
                                // TODO: Implement Add Media functionality
                                },
                              style: isDarkMode
                                  ? buttonStyles.blueOutlinedButtonDark()
                                  : buttonStyles.blueOutlinedButton(),
                              child: Text("+ Add media",
                                  style: TextStyles.font14_600Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkBlue
                                          : AppColors.lightBlue)),
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
                   style: buttonStyles.wideBlueElevatedButton().copyWith(
                       minimumSize: WidgetStateProperty.all(Size.fromHeight(50))),
                  onPressed: state is AddEducationLoading
                      ? null
                      : () => viewModel.saveEducation(), 
                  child: state is AddEducationLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.0))
                      : Text("Save",
                          style: TextStyles.font15_500Weight
                              .copyWith(color: AppColors.lightMain)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
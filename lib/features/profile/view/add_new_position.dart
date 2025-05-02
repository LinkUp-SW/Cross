import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:link_up/core/constants/constantvariables.dart';
import 'package:link_up/features/profile/state/add_position_state.dart';
import 'package:link_up/features/profile/viewModel/add_position_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_dropdown.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';
import 'package:link_up/features/profile/widgets/subpages_section_headers.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'dart:developer';


class AddNewPosition extends ConsumerStatefulWidget {
  const AddNewPosition({super.key});

  @override
  ConsumerState<AddNewPosition> createState() => _AddNewPositionState();
}

class _AddNewPositionState extends ConsumerState<AddNewPosition> {
  final FocusNode _startDateFocusNode = FocusNode();
  final FocusNode _endDateFocusNode = FocusNode();
  final FocusNode _companyFocusNode = FocusNode();

  @override
  void dispose() {
    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    _companyFocusNode.dispose();
    super.dispose();
  }

  AddPositionFormData? _getFormDataFromState(AddPositionState state) {
    if (state is AddPositionInitial) return state.formData;
    if (state is AddPositionLoading) return state.formData;
    if (state is AddPositionFailure) return state.formData;
    return null;
  }

    Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final viewModel = ref.read(addPositionViewModelProvider.notifier);
    final currentFormData = _getFormDataFromState(ref.read(addPositionViewModelProvider));

    if (currentFormData == null) return;
    if (!isStartDate && currentFormData.isCurrentPosition) return;

    final initialDate = isStartDate
        ? currentFormData.selectedStartDate ?? DateTime.now()
        : currentFormData.selectedEndDate ??
            currentFormData.selectedStartDate ??
            DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now().add(const Duration(days: 365 * 20));

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

    if (picked != null) {
      viewModel.setDate(picked, isStartDate);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(addPositionViewModelProvider);
    final viewModel = ref.read(addPositionViewModelProvider.notifier);
    final formData = _getFormDataFromState(state);

    ref.listen<AddPositionState>(addPositionViewModelProvider, (previous, next) {
      if (next is AddPositionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position saved successfully!'), backgroundColor: Colors.green),
        );
        GoRouter.of(context).pop();
      } else if (next is AddPositionFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.message}'), backgroundColor: Colors.red),
        );
      }
    });

    final maxDescriptionChars = viewModel.maxDescriptionChars;
    final descriptionCharCount = ref.watch(addPositionViewModelProvider.select(
        (s) => _getFormDataFromState(s)?.descriptionController.text.length ?? 0
    ));


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Add position",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                child: formData == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SubPagesIndicatesRequiredLabel(),
                            SizedBox(height: 10.h),
                            SubPagesFormLabel(label: "Title", isRequired: true),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.titleController,
                              hintText: "Ex: Retail Sales Manager",
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Employment type"),
                            SizedBox(height: 2.h),
                            SubPagesCustomDropdownFormField<String>(
                              value: formData.selectedEmploymentType,
                              hintText: "Please select",
                              items: jobTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                              onChanged: (value) => viewModel.setEmploymentType(value),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Company name", isRequired: true),
                            SizedBox(height: 2.h),
                            GestureDetector(
                              onTap: () async {
                                final selectedOrg = await GoRouter.of(context).push<Map<String, dynamic>>(
                                  '/search_organization',
                                  extra: formData.companyNameController.text,
                                );
                                if (selectedOrg != null) {
                                  viewModel.setOrganization(selectedOrg);
                                }
                              },
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.companyNameController,
                                  hintText: "Ex: Microsoft",
                                  focusNode: _companyFocusNode,
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Checkbox(
                                  value: formData.isCurrentPosition,
                                  onChanged: (value) {
                                    if (value != null) viewModel.setIsCurrentPosition(value);
                                  },
                                  activeColor: AppColors.lightGreen,
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
                            SizedBox(height: 10.h),
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
                            SubPagesFormLabel(label: "End date", isRequired: !formData.isCurrentPosition),
                            InkWell(
                              onTap: formData.isCurrentPosition ? null : () => _selectDate(context, false),
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.endDateController,
                                  hintText: formData.isCurrentPosition ? "Present" : "Select end date",
                                  focusNode: _endDateFocusNode,
                                  enabled: !formData.isCurrentPosition,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: formData.isCurrentPosition
                                        ? AppColors.lightGrey
                                        : (isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Location type"),
                            SizedBox(height: 2.h),
                            SubPagesCustomDropdownFormField<String>(
                              value: formData.selectedLocationType,
                              hintText: "Please select",
                              items: const [
                                DropdownMenuItem(value: "On-site", child: Text("On-site")),
                                DropdownMenuItem(value: "Remote", child: Text("Remote")),
                                DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
                              ],
                              onChanged: (value) => viewModel.setLocationType(value),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Location"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.locationController,
                              hintText: "Ex: London, United Kingdom",
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Description"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.descriptionController,
                              hintText: "Add details about your role...",
                              maxLines: null,
                              maxLength: maxDescriptionChars,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, right: 8.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "$descriptionCharCount / $maxDescriptionChars characters",
                                    style: TextStyles.font12_400Weight.copyWith(
                                      color: descriptionCharCount > maxDescriptionChars
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
                              "We recommend adding skills related to this position.",
                              style: TextStyles.font14_400Weight.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextColor
                                    : AppColors.lightTextColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ElevatedButton(
                              onPressed: () {

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
            if (formData != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AddPositionLoading ? null : () => viewModel.savePosition(),
                    style: (isDarkMode
                        ? buttonStyles.wideBlueElevatedButtonDark()
                        : buttonStyles.wideBlueElevatedButton())
                        .copyWith(minimumSize: MaterialStateProperty.all(Size.fromHeight(50.h))),
                    child: state is AddPositionLoading
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
    );
  }
}
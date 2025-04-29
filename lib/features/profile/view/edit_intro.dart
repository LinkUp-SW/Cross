import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/model/education_model.dart';
import 'package:link_up/features/profile/state/edit_intro_state.dart';
import 'package:link_up/features/profile/viewModel/edit_intro_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/features/profile/widgets/subpages_dropdown.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';
import 'package:link_up/features/profile/widgets/subpages_section_headers.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:link_up/features/profile/model/edit_intro_model.dart';
import 'dart:developer';

class EditIntroPage extends ConsumerStatefulWidget {
  const EditIntroPage({super.key});

  @override
  ConsumerState<EditIntroPage> createState() => _EditIntroPageState();
}

class _EditIntroPageState extends ConsumerState<EditIntroPage> {
  final _countryPickerController = TextEditingController();
  final _cityPickerController = TextEditingController();
  final _statePickerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countryPickerController.addListener(_handleCountryChange);
    _cityPickerController.addListener(_handleCityChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPickerControllers();
    });
  }

  void _handleCountryChange() {
    final viewModel = ref.read(editIntroViewModelProvider.notifier);
    if (viewModel.countryController.text != _countryPickerController.text) {
      log("Country picker changed: ${_countryPickerController.text}");
      viewModel.setCountry(_countryPickerController.text);
    }
  }

  void _handleCityChange() {
    final viewModel = ref.read(editIntroViewModelProvider.notifier);
    if (viewModel.cityController.text != _cityPickerController.text) {
      log("City picker changed: ${_cityPickerController.text}");
      viewModel.setCity(_cityPickerController.text);
    }
  }

  void _syncPickerControllers() {
    final state = ref.read(editIntroViewModelProvider);
    final viewModel = ref.read(editIntroViewModelProvider.notifier);
    String? country, city;

    if (state is EditIntroDataState) {
      country = state.formData.countryRegion;
      city = state.formData.city;
    } else if (state is EditIntroError && state.previousFormData != null) {
      country = state.previousFormData!.countryRegion;
      city = state.previousFormData!.city;
    } else if (state is EditIntroSaving) {
      country = state.formData.countryRegion;
      city = state.formData.city;
    }

    if (_countryPickerController.text != (country ?? '')) {
      _countryPickerController.text = country ?? '';
    }
    if (_cityPickerController.text != (city ?? '')) {
      _cityPickerController.text = city ?? '';
    }

    if (viewModel.countryController.text != (country ?? '')) {
      viewModel.countryController.text = country ?? '';
    }
    if (viewModel.cityController.text != (city ?? '')) {
      viewModel.cityController.text = city ?? '';
    }
  }

  @override
  void dispose() {
    _countryPickerController.removeListener(_handleCountryChange);
    _cityPickerController.removeListener(_handleCityChange);
    _countryPickerController.dispose();
    _cityPickerController.dispose();
    _statePickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(editIntroViewModelProvider);
    final viewModel = ref.read(editIntroViewModelProvider.notifier);

    EditIntroModel? formData;
    bool isLoading = false;
    bool isSaving = false;

    if (state is EditIntroLoading || state is EditIntroInitial) {
      isLoading = true;
    } else if (state is EditIntroDataState) {
      formData = state.formData;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncPickerControllers();
      });
    } else if (state is EditIntroSaving) {
      isSaving = true;
      formData = state.formData;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncPickerControllers();
      });
    } else if (state is EditIntroError) {
      formData = state.previousFormData;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncPickerControllers();
      });
    }

    ref.listen<EditIntroState>(editIntroViewModelProvider, (previous, next) {
      if (next is EditIntroSuccess) {
        if (previous is! EditIntroSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Intro saved successfully!'), backgroundColor: Colors.green),
          );
        }
        GoRouter.of(context).pop();
      } else if (next is EditIntroError) {
        if (previous is! EditIntroError || (previous as EditIntroError).message != next.message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${next.message}'), backgroundColor: Colors.red),
          );
        }
      }
      if ((previous is EditIntroLoading || previous is EditIntroError || previous is EditIntroSaving) && (next is EditIntroDataState)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncPickerControllers();
        });
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Edit intro",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : formData == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state is EditIntroError ? state.message : "Could not load profile data.",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.h),
                                  ElevatedButton(
                                    onPressed: () => viewModel.refetchForRetry(),
                                    child: const Text("Retry"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SubPagesIndicatesRequiredLabel(),
                                SizedBox(height: 10.h),
                                SubPagesFormLabel(label: "First Name", isRequired: true),
                                SizedBox(height: 2.h),
                                SubPagesCustomTextField(
                                  controller: viewModel.firstNameController,
                                  enabled: !isSaving,
                                  hintText: "Enter your first name",
                                ),
                                SizedBox(height: 20.h),
                                SubPagesFormLabel(label: "Last Name", isRequired: true),
                                SizedBox(height: 2.h),
                                SubPagesCustomTextField(
                                  controller: viewModel.lastNameController,
                                  enabled: !isSaving,
                                  hintText: "Enter your last name",
                                ),
                                SizedBox(height: 20.h),
                                SubPagesFormLabel(label: "Headline", isRequired: true),
                                SizedBox(height: 2.h),
                                SubPagesCustomTextField(
                                  controller: viewModel.headlineController,
                                  enabled: !isSaving,
                                  hintText: "Your professional headline",
                                  maxLines: null,
                                ),
                                SizedBox(height: 20.h),
                                GestureDetector(
                                  onTap: isSaving ? null : () => GoRouter.of(context).push('/add_new_position'),
                                  child: Text("+ Add new position", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightBlue)),
                                ),
                                SizedBox(height: 20.h),
                                SubPagesSectionHeader(title: "Education"),
                                SizedBox(height: 10.h),
                                SubPagesFormLabel(label: "School"),
                                SizedBox(height: 2.h),
                                SubPagesCustomDropdownFormField<String>(
                                  value: formData.selectedEducationId,
                                  hintText: "Select your highest/current education",
                                  items: [
                                  const DropdownMenuItem<String>(
                                  value: null, // Represents no selection
                                  child: Text("None"),
                                ),
                                  ...formData.availableEducations
                                    .where((edu) => edu.id != null) // Filter out items without an ID
                                    .map((edu) {
                                      return DropdownMenuItem<String>(
                                        value: edu.id!,
                                        child: Text(edu.institution, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: isSaving ? null : (value) => viewModel.setSelectedEducation(value),
                                ),
                                SizedBox(height: 10.h),
                                GestureDetector(
                                  onTap: isSaving ? null : () => GoRouter.of(context).push('/add_new_education'),
                                  child: Text("+ Add new education", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightBlue)),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: formData.showEducationInIntro,
                                      onChanged: isSaving ? null : (value) {
                                        if (value != null) viewModel.toggleShowEducation(value);
                                      },
                                      activeColor: AppColors.lightGreen,
                                      checkColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Show current education in my intro",
                                        style: TextStyles.font14_400Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                SubPagesSectionHeader(title: "Location"),
                                SizedBox(height: 10.h),
                                SubPagesFormLabel(label: "Country/Region", isRequired: true),
                                SizedBox(height: 2.h),
                                CountryStateCityPicker(
                                    country: _countryPickerController,
                                    state: _statePickerController,
                                    city: _cityPickerController,
                                    textFieldDecoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                                      filled: false,
                                      border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGrey)),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGrey)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue)),
                                      suffixIcon: Icon(Icons.arrow_drop_down, color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                      hintStyle: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                                    ),
                                    dialogColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                                ),
                                SizedBox(height: 20.h),
                                SubPagesSectionHeader(title: "Website"),
                                SizedBox(height: 10.h),
                                SubPagesFormLabel(label: "Personal or Company Website"),
                                SizedBox(height: 2.h),
                                SubPagesCustomTextField(
                                  controller: viewModel.websiteController,
                                  enabled: !isSaving,
                                  hintText: "e.g., https://www.yourwebsite.com",
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
                                        style: TextStyles.font14_400Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)
                                      ),
                                      SizedBox(height: 10.h),
                                      GestureDetector(
                                        onTap: isSaving ? null : () => GoRouter.of(context).push('/edit_contact_info'),
                                        child: Text("Edit contact info", style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightBlue)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
              ),
            ),
            if (!isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => viewModel.saveIntro(),
                    style: (isDarkMode
                        ? buttonStyles.wideBlueElevatedButtonDark()
                        : buttonStyles.wideBlueElevatedButton()
                    ).copyWith(minimumSize: MaterialStateProperty.all(Size.fromHeight(50.h))),
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                        : Text("Save", style: TextStyles.font15_500Weight.copyWith(color: isDarkMode ? AppColors.darkMain : AppColors.lightMain)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
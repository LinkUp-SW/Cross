import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:link_up/features/profile/state/license_state.dart';
import 'package:link_up/features/profile/viewModel/license_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';
import 'package:link_up/features/profile/widgets/subpages_section_headers.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/model/license_model.dart';

class AddNewLicensePage extends ConsumerStatefulWidget {
final LicenseModel? licenseToEdit;
const AddNewLicensePage({super.key, this.licenseToEdit});

  @override
  ConsumerState<AddNewLicensePage> createState() => _AddNewLicensePageState();
}



class _AddNewLicensePageState extends ConsumerState<AddNewLicensePage> {
  final FocusNode _issueDateFocusNode = FocusNode();
  final FocusNode _expirationDateFocusNode = FocusNode();
  final FocusNode _organizationFocusNode = FocusNode();
  final FocusNode _credentialIdFocusNode = FocusNode();
  final FocusNode _credentialUrlFocusNode = FocusNode();
  LicenseModel? _initialLicenseData;
  bool _isEditMode = false;
  List<String> _currentSkills = [];  

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extraData = GoRouterState.of(context).extra;
      LicenseModel? initialData;

      if (extraData is LicenseModel) {
        _initialLicenseData = extraData;
      } else {
        _initialLicenseData = widget.licenseToEdit;
      }

      if (initialData != null) {
        setState(() {
           _isEditMode = true; 
          _currentSkills = List<String>.from(initialData!.skills ?? []);

        });
        ref.read(addLicenseViewModelProvider.notifier).initializeForEdit(_initialLicenseData!);
      } else {
      ref.read(addLicenseViewModelProvider.notifier).resetForm();
         setState(() {
           _currentSkills = []; 
         });      }
    });
  }
  Future<void> _handleAddSkill() async {
  final TextEditingController _controller = TextEditingController();

  final newSkill = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Skill"),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkMain : AppColors.lightMain, 
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: "Enter skill name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: () {
            final value = _controller.text.trim();
            Navigator.pop(context, value);
          },
          child: Text("Add")
        ),
      ],
    ),
  );

  if (newSkill != null && newSkill.isNotEmpty && !_currentSkills.contains(newSkill)) {
    setState(() {
      _currentSkills.add(newSkill);
    });
  }
}



   void _removeSkill(String skillToRemove) {
      setState(() {
         _currentSkills.remove(skillToRemove);
      });
   }  
  @override
  void dispose() {
    _issueDateFocusNode.dispose();
    _expirationDateFocusNode.dispose();
    _organizationFocusNode.dispose();
    _credentialIdFocusNode.dispose();
    _credentialUrlFocusNode.dispose();
    super.dispose();
  }

  AddLicenseFormData? _getFormDataFromState(AddLicenseState state) {
    if (state is AddLicenseInitial) return state.formData;
    if (state is AddLicenseLoading) return state.formData;
    if (state is AddLicenseFailure) return state.formData;
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final viewModel = ref.read(addLicenseViewModelProvider.notifier);
    final currentFormData = _getFormDataFromState(ref.read(addLicenseViewModelProvider));

    if (currentFormData == null) return;
    if (!isIssueDate && currentFormData.doesNotExpire) return;

    final initialDate = isIssueDate
        ? currentFormData.selectedIssueDate ?? DateTime.now()
        : currentFormData.selectedExpirationDate ??
            currentFormData.selectedIssueDate ??
            DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now().add(const Duration(days: 365 * 50));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: ThemeData(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: AppColors.darkBlue,
                    onPrimary: AppColors.darkMain,
                    surface: AppColors.darkMain,
                    onSurface: AppColors.darkTextColor,
                  )
                : const ColorScheme.light(
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
      viewModel.setDate(picked, isIssueDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(addLicenseViewModelProvider);
    final viewModel = ref.read(addLicenseViewModelProvider.notifier);
    final String appBarTitle = _isEditMode ? "Edit License or Certificate" : "Add License or Certificate";
    final formData = _getFormDataFromState(state);
    final bool isSaving = state is AddLicenseLoading;

    ref.listen<AddLicenseState>(addLicenseViewModelProvider, (previous, next) {
      if (next is AddLicenseSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('License ${_isEditMode ? 'updated' : 'saved'} successfully!'), backgroundColor: Colors.green),
        );
         if (GoRouter.of(context).canPop()) {
             GoRouter.of(context).pop();
         }
          } else if (next is AddLicenseFailure) {
        if (previous is! AddLicenseFailure || previous.message != next.message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${next.message}'), backgroundColor: Colors.red),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: appBarTitle,
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
                            SubPagesFormLabel(label: "Name", isRequired: true),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.nameController,
                              enabled: !isSaving,
                              hintText: "Ex: Certified Cloud Practitioner",
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Issuing Organization", isRequired: true),
                            SizedBox(height: 2.h),
                            GestureDetector(
                              onTap: isSaving
                                  ? null
                                  : () async {
                                      final selectedOrg = await GoRouter.of(context).push<Map<String, dynamic>>(
                                        '/search_organization',
                                        extra: formData.organizationController.text,
                                      );
                                      if (selectedOrg != null) {
                                        viewModel.setOrganization(selectedOrg);
                                      }
                                    },
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.organizationController,
                                  enabled: !isSaving,
                                  hintText: "Ex: Amazon Web Services (AWS)",
                                  focusNode: _organizationFocusNode,
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
                                  value: formData.doesNotExpire,
                                  onChanged: isSaving
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            viewModel.setDoesNotExpire(value);
                                          }
                                        },
                                  activeColor: AppColors.lightGreen,
                                  checkColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                                ),
                                Text(
                                  "This credential does not expire",
                                  style: TextStyles.font14_400Weight.copyWith(
                                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            SubPagesFormLabel(label: "Issue date", isRequired: true),
                            InkWell(
                              onTap: isSaving ? null : () => _selectDate(context, true),
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.issueDateController,
                                  enabled: !isSaving,
                                  hintText: "Select issue date",
                                  focusNode: _issueDateFocusNode,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Expiration date", isRequired: !formData.doesNotExpire),
                            InkWell(
                              onTap: (isSaving || formData.doesNotExpire) ? null : () => _selectDate(context, false),
                              child: AbsorbPointer(
                                child: SubPagesCustomTextField(
                                  controller: formData.expirationDateController,
                                  enabled: !isSaving && !formData.doesNotExpire,
                                  hintText: formData.doesNotExpire ? "Does not expire" : "Select expiration date",
                                  focusNode: _expirationDateFocusNode,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: (isSaving || formData.doesNotExpire)
                                        ? AppColors.lightGrey
                                        : (isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Credential ID"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.credentialIdController,
                              enabled: !isSaving,
                              hintText: "Enter credential ID (optional)",
                              focusNode: _credentialIdFocusNode,
                            ),
                            SizedBox(height: 20.h),
                            SubPagesFormLabel(label: "Credential URL"),
                            SizedBox(height: 2.h),
                            SubPagesCustomTextField(
                              controller: formData.credentialUrlController,
                              enabled: !isSaving,
                              hintText: "Enter URL (optional, e.g., https://verify.com/123)",
                              focusNode: _credentialUrlFocusNode,
                            ),
                            SizedBox(height: 20.h),
                        SubPagesSectionHeader(title: "Skills"),
                         SizedBox(height: 10.h),
                         Text(
                           "Add skills related to this position.", 
                           style: TextStyles.font14_400Weight.copyWith(
                             color: isDarkMode
                                 ? AppColors.darkTextColor
                                 : AppColors.lightTextColor,
                           ),
                         ),
                         SizedBox(height: 10.h),

                         Wrap(
                            spacing: 8.w,
                            runSpacing: 4.h,
                            children: _currentSkills.map((skill) => Chip(
                               label: Text(skill, style: TextStyles.font12_500Weight.copyWith(color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor)),
                               onDeleted: isSaving ? null : () => _removeSkill(skill),
                               deleteIcon: Icon(Icons.close, size: 14.sp),
                               backgroundColor: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.2),
                               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                               shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  side: BorderSide(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.5))
                               ),
                            )).toList(),
                         ),
                        ElevatedButton(
                           onPressed: isSaving ? null : _handleAddSkill, 
                                style: isDarkMode
                                    ? buttonStyles.blueOutlinedButtonDark()
                                    : buttonStyles.blueOutlinedButton(),
                                child: Text("+ Add Skill",
                                    style: TextStyles.font14_600Weight.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkBlue
                                            : AppColors.lightBlue)),
                              ),
                         // --- End Skills Section ---
                            SizedBox(height: 20.h),
                            SubPagesSectionHeader(title: "Media"),
                            SizedBox(height: 10.h),
                            Text(
                              "Add or link to external documents, photos, sites, videos, or presentations.",
                              style: TextStyles.font14_400Weight.copyWith(
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ElevatedButton(
                              onPressed: isSaving ? null : () {},
                              style: isDarkMode
                                  ? buttonStyles.blueOutlinedButtonDark()
                                  : buttonStyles.blueOutlinedButton(),
                              child: Text(
                                "+ Add media",
                                style: TextStyles.font14_600Weight.copyWith(
                                  color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                                ),
                              ),
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
                                onPressed: state is AddLicenseLoading ? null : () => viewModel.saveLicense(_currentSkills),
                                style: (isDarkMode
                                    ? buttonStyles.wideBlueElevatedButtonDark()
                                    : buttonStyles.wideBlueElevatedButton())
                                    .copyWith(minimumSize: MaterialStateProperty.all(Size.fromHeight(50.h))),
                                child: state is AddLicenseLoading
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
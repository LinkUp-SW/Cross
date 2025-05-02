// profile/view/add_new_skill.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/model/skills_model.dart';
import 'package:link_up/features/profile/state/skills_state.dart';
import 'package:link_up/features/profile/viewModel/add_skill_view_model.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/features/profile/widgets/subpages_form_labels.dart';
import 'package:link_up/features/profile/widgets/subpages_indication.dart';
import 'package:link_up/features/profile/widgets/subpages_text_field.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'dart:developer';

class AddSkillPage extends ConsumerWidget {
  const AddSkillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonStyles = LinkUpButtonStyles();
    final state = ref.watch(addSkillViewModelProvider);
    final viewModel = ref.read(addSkillViewModelProvider.notifier);

    ref.listen<AddSkillState>(addSkillViewModelProvider, (previous, next) {
      if (next is AddSkillSuccess) {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skill added successfully!'), backgroundColor: Colors.green),
            );
            GoRouter.of(context).pop();
        }
      } else if (next is AddSkillError) {
         if (context.mounted && (previous is! AddSkillError || previous.message != next.message)) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(next.message), backgroundColor: Colors.red),
             );
         }
      }
    });

    Widget buildContent() {
      switch (state) {
        case AddSkillInitial():
        case AddSkillLoadingItems():
          return const Center(child: CircularProgressIndicator());

        case AddSkillError(:final message, :final previousData):
           return Center(
              child: Padding(
                 padding: EdgeInsets.all(20.w),
                 child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text("Error: $message", style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
                       SizedBox(height: 10.h),
                       if (previousData == null)
                         ElevatedButton(
                            onPressed: () => viewModel.loadLinkableItems(),
                            child: const Text("Retry Loading"),
                         )
                       else
                         Container(),
                    ],
                 ),
              ),
           );

        case AddSkillSaving(:final previousData):
        case AddSkillDataLoaded():
          final data = (state is AddSkillDataLoaded)
              ? state
              : (state as AddSkillSaving).previousData;
          final bool isSaving = state is AddSkillSaving;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          bool hasLinkableItems = data.availableExperiences.isNotEmpty ||
                                  data.availableEducations.isNotEmpty ||
                                  data.availableLicenses.isNotEmpty;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SubPagesIndicatesRequiredLabel(),
                SizedBox(height: 10.h),
                SubPagesFormLabel(label: "Skill", isRequired: true),
                SizedBox(height: 2.h),
                SubPagesCustomTextField(
                  controller: viewModel.skillNameController,
                  enabled: !isSaving,
                  hintText: "Ex: Project Management",
                ),
                SizedBox(height: 25.h),

                if (!hasLinkableItems)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: Text(
                        "No associated items found.",
                        textAlign: TextAlign.center,
                        style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Show us where you used this skill",
                         style: TextStyles.font16_600Weight.copyWith(
                           color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                         ),
                      ),
                       SizedBox(height: 4.h),
                       Text(
                         "Optionally, select items below to show where you used this skill. This provides context for recruiters.",
                         style: TextStyles.font14_400Weight.copyWith(color: AppColors.lightGrey),
                       ),
                       SizedBox(height: 15.h),

                      if (data.availableExperiences.isNotEmpty) ...[
                        Text("Experience", style: TextStyles.font16_600Weight),
                        ...data.availableExperiences.map((item) => CheckboxListTile(
                              title: Text(item.title, style: TextStyles.font14_400Weight),
                              subtitle: Text(item.subtitle, style: TextStyles.font12_400Weight.copyWith(color: AppColors.lightGrey)),
                              value: data.selectedExperienceIds.contains(item.id),
                              onChanged: isSaving ? null : (bool? value) {
                                viewModel.toggleLink(item.id, item.type);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.lightGreen,
                            )),
                        SizedBox(height: 15.h),
                      ],

                      if (data.availableEducations.isNotEmpty) ...[
                        Text("Education", style: TextStyles.font16_600Weight),
                        ...data.availableEducations.map((item) => CheckboxListTile(
                               title: Text(item.subtitle, style: TextStyles.font14_400Weight),
                               subtitle: Text(item.title, style: TextStyles.font12_400Weight.copyWith(color: AppColors.lightGrey)),
                              value: data.selectedEducationIds.contains(item.id),
                              onChanged: isSaving ? null : (bool? value) {
                                viewModel.toggleLink(item.id, item.type);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                               activeColor: AppColors.lightGreen,
                            )),
                        SizedBox(height: 15.h),
                      ],

                      if (data.availableLicenses.isNotEmpty) ...[
                        Text("Licenses & certifications", style: TextStyles.font16_600Weight),
                        ...data.availableLicenses.map((item) => CheckboxListTile(
                              title: Text(item.title, style: TextStyles.font14_400Weight),
                              subtitle: Text(item.subtitle, style: TextStyles.font12_400Weight.copyWith(color: AppColors.lightGrey)),
                              value: data.selectedLicenseIds.contains(item.id),
                              onChanged: isSaving ? null : (bool? value) {
                                viewModel.toggleLink(item.id, item.type);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                               activeColor: AppColors.lightGreen,
                            )),
                        SizedBox(height: 15.h),
                      ],
                    ],
                  ),
              ],
            ),
          );
         case AddSkillSuccess():
           return const SizedBox.shrink();
      }
    }

    bool canSave = false;
    if (state is AddSkillDataLoaded) {
       canSave = state.canSave;
    } else if (state is AddSkillSaving) {
       canSave = false;
    } else if (state is AddSkillError && state.previousData != null) {
        canSave = state.previousData!.copyWith(currentSkillName: viewModel.skillNameController.text).canSave;
    }

    return Scaffold(
       backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
       body: SafeArea(
         child: Column(
           children: [
             SubPagesAppBar(
               title: "Add skill",
               onClosePressed: () => GoRouter.of(context).pop(),
             ),
             Expanded(
               child: Container(
                 color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                 child: buildContent(),
               ),
             ),
             if (state is AddSkillDataLoaded || state is AddSkillSaving || (state is AddSkillError && state.previousData != null))
               Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                 child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: (!canSave || state is AddSkillSaving) ? null : () => viewModel.saveSkill(),
                     style: (isDarkMode
                             ? buttonStyles.wideBlueElevatedButtonDark()
                             : buttonStyles.wideBlueElevatedButton())
                         .copyWith(
                           minimumSize: WidgetStateProperty.all(Size.fromHeight(50.h)),
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return AppColors.lightGrey;
                                }
                                return isDarkMode ? AppColors.darkBlue : AppColors.lightBlue;
                              },
                           ),
                         ),
                     child: state is AddSkillSaving
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
//the page ui only and try avoiding any logic here
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/widgets/job_card_refactor.dart';
import 'package:link_up/features/jobs/widgets/jobs_section.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class JobsScreen extends ConsumerWidget {
  final bool isDarkMode;

  const JobsScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        searchBar: const CustomSearchBar(),
        leadingAction: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.h,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: isDarkMode
                        ? LinkUpButtonStyles().jobsPreferencesDark()
                        : LinkUpButtonStyles().jobsPreferencesLight(),
                    child: Text(
                      'Preferences',
                      style: TextStyles.font15_700Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightGrey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: isDarkMode
                        ? LinkUpButtonStyles().jobsPreferencesDark()
                        : LinkUpButtonStyles().jobsPreferencesLight(),
                    child: Text(
                      'My jobs',
                      style: TextStyles.font15_700Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightGrey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: isDarkMode
                        ? LinkUpButtonStyles().jobsPreferencesDark()
                        : LinkUpButtonStyles().jobsPreferencesLight(),
                    child: Text(
                      'Post a free job',
                      style: TextStyles.font15_700Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            JobsSection(
              isDarkMode: isDarkMode,
              title: 'Job picks for you',
              description:
                  'Based on your profile, preferences, and activity like applies, searches, and saves',
              jobs: [
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
           
            JobsSection(
              isDarkMode: isDarkMode,
              title: 'More jobs for you',
              description:
                  'Based on your profile, preferences, and activity like applies, searches, and saves',
              jobs: [
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
                JobsCard(
                  data: JobsCardModel.initial(),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
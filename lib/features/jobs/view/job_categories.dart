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
import 'package:link_up/features/jobs/widgets/job_categories.dart';
import 'package:link_up/features/jobs/model/jobs_screen_categories_model.dart';
import 'package:link_up/features/jobs/widgets/categories_section.dart';

class JobsCategoriesView extends ConsumerWidget {
  final bool isDarkMode;

  const JobsCategoriesView({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        JobCategoryCard(
          isDarkMode: isDarkMode,
          description: 'Find jobs by your preferred category',
          categories: JobsCategoryModel.getAllCategories().map((category) =>
            JobCategory(
              data: category,
              isDarkMode: isDarkMode,
            ),
          ).toList(),
          jobs: [
            JobsCard(
              isDarkMode: isDarkMode,
              data: JobsCardModel.initial(),
            ),
            JobsCard(
              isDarkMode: isDarkMode,
              data: JobsCardModel.initial(),
            ),
          ],
        ),
      ],
    );
  }
}
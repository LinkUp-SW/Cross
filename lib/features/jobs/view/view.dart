import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/view/search_jobs_page.dart';
import 'package:link_up/features/jobs/viewModel/jobs_screen_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_card_refactor.dart';
import 'package:link_up/features/jobs/widgets/jobs_section.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/features/jobs/view/my_jobs_screen.dart';


class JobsScreen extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const JobsScreen({
    super.key,
    required this.scaffoldKey,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>_CreateJobsScreenState();

    
  
}
class _CreateJobsScreenState extends ConsumerState <JobsScreen>{

Future<void> _refreshJobs() async {
  final viewModel = ref.read(jobsScreenViewModelProvider.notifier);
  await Future.wait([
    viewModel.getTopJobs({'limit': 3, 'cursor': null}),
    viewModel.getAllJobs({'limit': 10, 'cursor': null}),
  ]);
}

@override
  void initState() {
    super.initState();
    Future.microtask(() {
      _refreshJobs();
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsScreenViewModelProvider);
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        searchBar: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchJobsPage(),
              ),
            );
          },
          child: Container(
            height: 35.h,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    size: 20.sp,
                  ),
                ),
                Text(
                  'Search jobs',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingAction: () {
          widget.scaffoldKey.currentState!.openDrawer();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyJobsScreen(),
                          ),
                        );
                      },
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
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.isError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading jobs: ${state.errorMessage}',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: _refreshJobs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    JobsSection(
                      isDarkMode: isDarkMode,
                      title: 'Job picks for you',
                      description:
                          'Based on your profile, preferences, and activity like applies, searches, and saves',
                      jobs: state.topJobPicksForYou
                          .map((job) => JobsCard(isDarkMode: isDarkMode, data: job))
                          .toList(),
                    ),
                    JobsSection(
                      isDarkMode: isDarkMode,
                      title: 'More jobs for you',
                      description:
                          'Based on your profile, preferences, and activity like applies, searches, and saves',
                      jobs: state.moreJobsForYou
                          .map((job) => JobsCard(isDarkMode: isDarkMode, data: job))
                          .toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

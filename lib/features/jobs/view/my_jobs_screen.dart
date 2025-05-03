import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/view/job_details.dart';
import 'package:link_up/features/jobs/viewModel/my_jobs_view_model.dart';
import 'package:link_up/features/jobs/widgets/empty_jobs_state.dart';
import 'package:link_up/features/jobs/widgets/saved_job_card.dart';
import 'package:link_up/shared/themes/colors.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myJobsViewModelProvider.notifier).getSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobsViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (state.savedJobs.isEmpty) {
      return EmptyJobsState(
        isDarkMode: isDarkMode,
        onSearchTap: () {
          // Navigate to search screen
          // TODO: Implement navigation to search screen
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.savedJobs.length,
        itemBuilder: (context, index) {
          final job = state.savedJobs[index];
          return SavedJobCard(
            job: job,
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsPage(jobId: job.jobId),
                ),
              );
            },
            onUnsave: () {
              ref.read(myJobsViewModelProvider.notifier).unsaveJob(job.jobId);
            },
          );
        },
      ),
    );
  }
} 
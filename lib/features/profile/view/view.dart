import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart';
import 'package:link_up/features/profile/widgets/profile_app_bar_widget.dart';
import 'package:link_up/features/profile/widgets/profile_header_widget.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart';
import 'package:link_up/features/profile/state/profile_state.dart';


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Call fetchUserProfile without arguments to fetch the logged-in user's profile
      ref.read(profileViewModelProvider.notifier).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final educationState = ref.watch(educationDataProvider); 
    final experienceState = ref.watch(experienceDataProvider);
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
           // Call fetchUserProfile without arguments on refresh
           await ref.read(profileViewModelProvider.notifier).fetchUserProfile();
        },
        child: switch (profileState) {
          ProfileLoading() => const Center(child: CircularProgressIndicator()),

          ProfileError(:final message) => Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      Text('Error: $message', textAlign: TextAlign.center),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        // Call fetchUserProfile without arguments on retry
                        onPressed: () => ref.read(profileViewModelProvider.notifier).fetchUserProfile(),
                        child: const Text('Retry'),
                      )
                   ],
                ),
              ),
            ),

          ProfileLoaded(:final userProfile) => SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeaderWidget(userProfile: userProfile),
                  SectionWidget(
                    title: "Education",
                    child: educationState == null || educationState.isEmpty
                    ? const Text("No education added yet.")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: educationState.map((edu) {
                            return ListTile(
                              leading: Icon(Icons.school, size: 20.sp, color: Colors.blue),
                              title:   Text(edu.institution,
                            style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                        ),
                  ),
                   SectionWidget(
                    title: "Experience",
                    child: experienceState == null || experienceState.isEmpty
                      ? const Text("No experience added yet.")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: experienceState.map((exp) {
                            return ListTile(
                               leading: Icon(Icons.work, size: 20.sp, color: Colors.green),
                               title: Text(exp.title, style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                        ),
                  ),
                   SectionWidget(
                     title: "Skills",
                     child: Column(
                       children: [
                         Text("Flutter, Dart, Riverpod", style: TextStyle(fontSize: 14.sp)),
                       ],
                     ),
                   ),
                ],
              ),
            ),

          ProfileInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
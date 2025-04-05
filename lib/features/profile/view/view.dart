import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/profile/widgets/profile_app_bar_widget.dart';
import 'package:link_up/features/profile/widgets/profile_header_widget.dart'; // Import the header widget
import 'package:link_up/features/profile/widgets/section_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: SingleChildScrollView(  
        child: Column(
          children: [
             ProfileHeaderWidget(), 
            SectionWidget(
              title: "Education",
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, size: 20.sp, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Text("Cairo University", style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text("2025", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
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
    );
  }
}

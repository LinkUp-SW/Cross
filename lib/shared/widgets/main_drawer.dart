import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/logIn/viewModel/user_data_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/profile');
                    log('Profile tapped');
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250.w,
                      decoration: const BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundImage: NetworkImage(userData.profileUrl),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text('John Doe',
                              style: TextStyle(
                                  fontSize: 20.r, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text('view profile',
                              style: TextStyle(
                                  fontSize: 12.r, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('X profile viewers'),
                  onTap: () {
                    context.push('/profileViews');
                  },
                ),
                ListTile(
                  title: const Text('View all analytics'),
                  onTap: () {
                    context.push('/analytics');
                  },
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                // ListTile(
                //   title: const Text('Puzzle games'),
                //   onTap: () {
                //     context.push('/puzzles');
                //   },
                // ),
                ListTile(
                  title: const Text('Saved posts'),
                  onTap: () {
                    context.push('/savedPosts');
                  },
                ),
                ListTile(
                  title: const Text('Groups'),
                  onTap: () {
                    context.push('/groups');
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('Try Premium for EGP0'),
                  onTap: () {
                    context.push('/premium');
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () {
                    context.push('/settings');
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    logout(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

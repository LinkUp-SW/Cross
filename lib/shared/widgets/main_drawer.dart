import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/shared/themes/colors.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                    log('Profile tapped');
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      decoration: const BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(InternalEndPoints.profileUrl),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              '${InternalEndPoints.userId.split('-')[0][0].toUpperCase()}${InternalEndPoints.userId.split('-')[0].substring(1)} ${InternalEndPoints.userId.split('-')[1][0].toUpperCase()}${InternalEndPoints.userId.split('-')[1].substring(1)}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('view profile',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('X profile viewers'),
                  onTap: () {
                    context.pop();
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
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    context.push('/settings');
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

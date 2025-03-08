

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                    log('profile');
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
                            backgroundImage: const NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text('John Doe',
                              style:
                                  TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text('view profile', style: TextStyle(fontSize: 12.r)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('Home'),
                  onTap: () {
                    context.push('/');
                  },
                ),
                ListTile(
                  title: const Text('Profile'),
                  onTap: () {
                    context.push('/profile');
                  },
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () {
                    context.push('/settings');
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    context.push('/login');
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    context.push('/login');
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('About'),
                  onTap: () {
                    context.push('/about');
                  },
                ),
                ListTile(
                  title: const Text('Help'),
                  onTap: () {
                    context.push('/help');
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

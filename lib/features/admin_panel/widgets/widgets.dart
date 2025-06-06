import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/shared/themes/colors.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/statistics');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.grey,
                          size: 30.r,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          'Statistics',
                          style: TextStyle(
                              fontSize: 20.r, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/priv');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: AppColors.grey,
                          size: 30.r,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          'Privileges',
                          style: TextStyle(
                              fontSize: 20.r, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/login');
                logout(context);
                log('Logout tapped');
              },
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: AppColors.grey,
                    size: 30.r,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    'Logout',
                    style:
                        TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

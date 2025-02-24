import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    // Get the current route location to determine the selected index
    // final String location = GoRouterState.of(context).uri.toString();

    // Map routes to indices
    // int getCurrentIndex(String location) {
    //   switch (location) {
    //     case '/':
    //       return 0;
    //     case '/video':
    //       return 1;
    //     case '/network':
    //       return 2;
    //     case '/notifications':
    //       return 3;
    //     case '/jobs':
    //       return 4;
    //     default:
    //       return 0;
    //   }
    // }

    // final currentIndex = getCurrentIndex(location);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (int index) => navigationShell.goBranch(index),
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
            icon: _buildNavItem(
              context,
              currentIndex: currentIndex,
              index: 0,
              asset: Icons.home,
            ),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: _buildNavItem(
              context,
              currentIndex: currentIndex,
              index: 1,
              asset: Icons.video_library,
            ),
            label: 'Video'),
        BottomNavigationBarItem(
            icon: _buildNavItem(
              context,
              currentIndex: currentIndex,
              index: 2,
              asset: Icons.people,
            ),
            label: 'My Network'),
        BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: AppColors.red,
              textColor: AppColors.lightMain,
              //TODO: Need to be changed to the real number of notifications
              label: const Text("3"),
              offset: const Offset(-10, 0),
              child: _buildNavItem(
                context,
                currentIndex: currentIndex,
                index: 3,
                asset: Icons.notifications,
              ),
            ),
            label: 'Notifications'),
        BottomNavigationBarItem(
            icon: _buildNavItem(
              context,
              currentIndex: currentIndex,
              index: 4,
              asset: Icons.work,
            ),
            label: 'Jobs'),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int currentIndex,
    required int index,
    required IconData asset,
  }) {
    final isSelected = currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color borderColor;
    if (isDarkMode) {
      // In dark mode, switch the colors
      borderColor =
          isSelected ? AppColors.darkSecondaryText : AppColors.darkMain;
    } else {
      // In light mode, keep the original colors
      borderColor = isSelected ? AppColors.lightTextColor : AppColors.lightMain;
    }
    return SizedBox(
      height: 30.h,
      width: 60.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0.w, -5.h),
            child: Container(
              height: 2.0.h, // Height of the top border
              color: borderColor,
            ),
          ),
          Icon(
            asset,
            size: 24.h,
          ),
        ],
      ),
    );
  }
}

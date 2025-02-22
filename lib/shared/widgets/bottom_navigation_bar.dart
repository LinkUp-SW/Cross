import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current route location to determine the selected index
    final String location = GoRouterState.of(context).uri.toString();

    // Map routes to indices
    int getCurrentIndex(String location) {
      switch (location) {
        case '/':
        case '/home':
          return 0;
        case '/video':
          return 1;
        case '/network':
          return 2;
        case '/notifications':
          return 3;
        case '/jobs':
          return 4;
        default:
          return 0;
      }
    }

    final currentIndex = getCurrentIndex(location);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (int index) {
        // Navigate to the corresponding route when an item is tapped
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/video');
            break;
          case 2:
            context.go('/network');
            break;
          case 3:
            context.go('/notifications');
            break;
          case 4:
            context.go('/jobs');
            break;
        }
      },
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
            icon: _buildNavItem(
              context,
              currentIndex: currentIndex,
              index: 3,
              asset: Icons.notifications,
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

  Widget _buildNavItem(BuildContext context,
      {required int currentIndex,
      required int index,
      required IconData asset}) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    final color = isSelected ? theme.primaryColor : theme.colorScheme.onSurface;

    return SizedBox(
      height: 35.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -8), // Shift upwards by 6 pixels
            child: Container(
              height: 4.0.h, // Height of the top border
              width: 94.0.w, // Adjust the width to match your design
              color: isSelected
                  ? AppColors.lightTextColor
                  : AppColors.lightSecondaryText,
            ),
          ),
          Icon(
            asset,
            size: 24.h,
            color: color,
          ),
        ],
      ),
    );
  }
}

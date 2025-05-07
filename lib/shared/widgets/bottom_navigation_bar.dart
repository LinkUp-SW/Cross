import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/notifications/viewModel/notification_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/tab_provider.dart';



class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) {
          if (index == 3) { 
    // Refresh unread count when tapping notifications tab
    ref.read(notificationsViewModelProvider.notifier).fetchUnreadCount();
         }
        index == currentIndex
            ? ref.read(currentTabProvider.notifier).state = true
            : navigationShell.goBranch(index);
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
              asset: Icons.people,
            ),
            label: 'My Network'),
        BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                context.push('/writePost');
              },
              child: _buildNavItem(
                context,
                currentIndex: currentIndex,
                index: 2,
                asset: Icons.add_box,
              ),
            ),
            label: 'Post'),
        BottomNavigationBarItem(
          icon: Consumer(
            builder: (context, ref, child) {
              final notificationState =
                  ref.watch(notificationsViewModelProvider);
              final unreadCount= notificationState.unreadCount;

              return Badge(
                backgroundColor: AppColors.red, textColor: AppColors.lightMain,
                label:
                    Text(unreadCount.toString()), 
                    isLabelVisible: unreadCount > 0,//  Show dynamic unread count
                offset: const Offset(-10, 0),
                child: _buildNavItem(
                  context,
                  currentIndex: currentIndex,
                  index: 3,
                  asset: Icons.notifications,
                ),
              );
            },
          ),
          label: 'Notifications',
        ),
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
          isSelected ? AppColors.darkSecondaryText : AppColors.darkGrey;
    } else {
      // In light mode, keep the original colors
      borderColor = isSelected ? AppColors.lightTextColor : AppColors.lightGrey;
    }
    return SizedBox(
      height: 30.h,
      width: 120.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0.w, -6.h),
            child: Container(
              height: isSelected ? 0.9.h : 0.2.h, // Height of the top border
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

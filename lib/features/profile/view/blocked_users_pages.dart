import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/state/blocked_users_state.dart';
import 'package:link_up/features/profile/viewModel/blocked_users_view_model.dart';
import 'package:link_up/features/profile/widgets/blocked_list_item_widget.dart'; 
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blockedUsersViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDarkMode ? AppColors.darkMain : AppColors.lightMain;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor, 
        elevation: 0, 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => GoRouter.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Blocked Users',
          style: TextStyles.font18_700Weight.copyWith(color: textColor),
        ),
        centerTitle: false, 
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(blockedUsersViewModelProvider.notifier).fetchBlockedUsers(),
        child: switch (state) {
          BlockedUsersInitial() || BlockedUsersLoading() => const Center(child: CircularProgressIndicator()),
          BlockedUsersError(:final message) => Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Error: $message',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          BlockedUsersLoaded(:final users) => Container(
              margin: EdgeInsets.all(16.w), 
              decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8.r),
              
              ),
              child: Column(
                 mainAxisSize: MainAxisSize.min, 
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                     child: Text(
                       users.isEmpty
                           ? "You haven't blocked any users."
                           : "You're blocking ${users.length} user${users.length == 1 ? '' : 's'}",
                       style: TextStyles.font14_400Weight.copyWith(color: secondaryTextColor),
                     ),
                   ),
                  if (users.isNotEmpty)
                     Expanded(
                      child: ListView.separated(
                         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                         itemCount: users.length,
                         itemBuilder: (context, index) {
                           return BlockedUserListItem(user: users[index]);
                         },
                         separatorBuilder: (context, index) => Divider(
                           height: 1.h,
                           thickness: 0.5,
                           color: isDarkMode ? AppColors.darkGrey.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3),
                         ),
                       ),
                    ),
                  if (users.isEmpty) 
                     SizedBox(height: 20.h),
                 ],
               ),
             ),
         },
       ),
      );
    
  }
}
// profile/widgets/blocked_user_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/profile/model/blocked_user_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/utils/profile_view_helpers.dart';
import 'package:link_up/features/profile/viewModel/blocked_users_view_model.dart'; 
import 'package:link_up/features/profile/state/blocked_users_state.dart';      
import 'package:link_up/features/profile/widgets/unblock_confirmation_dialog.dart'; 
import 'dart:developer';

class BlockedUserListItem extends ConsumerWidget {
  final BlockedUser user;

  const BlockedUserListItem({
    super.key,
    required this.user,
  });

  Future<void> _handleUnblock(BuildContext context, WidgetRef ref, BlockedUser user) async {
    final password = await showUnblockConfirmationDialog(context, user.name);

    if (password != null && password.isNotEmpty && context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Unblocking ${user.name}...'), duration: const Duration(seconds: 2)),
       );

      try {
        final success = await ref.read(blockedUsersViewModelProvider.notifier).unblockUser(user.userId, password);


        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.name} unblocked successfully.'), backgroundColor: Colors.green),
          );
        }

      } catch (e) {
          log("Error caught in UI during unblock: $e");
         if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error unblocking: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: Colors.red),
            );
         }
      }
    } else {
      log("Unblock cancelled or password empty.");
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = AppColors.lightGrey;
    final unblockButtonColor = Colors.red.shade700;

    final pageState = ref.watch(blockedUsersViewModelProvider);
    bool isThisUserUnblocking = pageState is BlockedUsersUnblocking && pageState.unblockingUserId == user.userId;


    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(
            Icons.block,
            color: secondaryTextColor,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyles.font16_600Weight.copyWith(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  formatTimeAgo(user.date),
                  style: TextStyles.font12_400Weight.copyWith(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          isThisUserUnblocking
              ? SizedBox(
                  height: 24.h, 
                  width: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: unblockButtonColor,
                  ),
                )
              : TextButton(
                  onPressed: () => _handleUnblock(context, ref, user), 
                  style: TextButton.styleFrom(
                    foregroundColor: unblockButtonColor,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Unblock",
                    style: TextStyles.font14_600Weight.copyWith(color: unblockButtonColor),
                  ),
                ),
        ],
      ),
    );
  }
}
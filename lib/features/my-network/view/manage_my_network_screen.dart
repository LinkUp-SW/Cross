import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/widgets/manage_my_network_screen_navigation_row.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class ManageMyNetworkScreen extends ConsumerWidget {
  final bool isDarkMode;

  const ManageMyNetworkScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Manage my network',
          style: TextStyles.font20_700Weight.copyWith(
            color: isDarkMode ? AppColors.darkGrey : AppColors.lightTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25.w,
            color: isDarkMode
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            height: 40.h,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              child: Row(
                children: [
                  Text(
                    'Manage my network',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: isDarkMode,
            icon: Icons.people,
            title: 'Connections',
            onTap: () => context.push('/connections'),
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: isDarkMode,
            icon: Icons.person,
            title: 'People I follow',
            onTap: () => context.push('/following'),
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: isDarkMode,
            icon: Icons.business,
            title: 'Pages',
            onTap: () => context.push('/pages'),
          ),
        ],
      ),
    );
  }
}

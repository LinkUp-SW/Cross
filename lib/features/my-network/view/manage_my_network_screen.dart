import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/viewModel/manage_my_network_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/manage_my_network_screen_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

// Change to StatefulConsumerWidget to handle async initialization
class ManageMyNetworkScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const ManageMyNetworkScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<ManageMyNetworkScreen> createState() =>
      _ManageMyNetworkScreenState();
}

class _ManageMyNetworkScreenState extends ConsumerState<ManageMyNetworkScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    Future.microtask(() {
      ref
          .read(manageMyNetworkScreenViewModelProvider.notifier)
          .getManageMyNetworkScreenCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state to react to changes
    final state = ref.watch(manageMyNetworkScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Manage my network',
          style: TextStyles.font20_700Weight.copyWith(
            color: widget.isDarkMode
                ? AppColors.darkGrey
                : AppColors.lightTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25.w,
            color: widget.isDarkMode
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
              color:
                  widget.isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: widget.isDarkMode
                      ? AppColors.darkGrey
                      : AppColors.lightGrey,
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
                      color: widget.isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: widget.isDarkMode,
            icon: Icons.people,
            title: 'Connections',
            onTap: () => context.push('/connections'),
            // Use the count from state, show loading indicator if still loading
            count: state.isLoading ? 0 : state.connectionsCount,
            isLoading: state.isLoading,
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: widget.isDarkMode,
            icon: Icons.person,
            title: 'People I follow',
            onTap: () => context.push('/following'),
            count: state.isLoading ? 0 : state.followingCount,
            isLoading: state.isLoading,
          ),
          ManageMyNetworkScreenNavigationRow(
            isDarkMode: widget.isDarkMode,
            icon: Icons.business,
            title: 'Pages',
            onTap: () => context.push('/pages'),
            count: state.isLoading ? 0 : state.pagesCount,
            isLoading: state.isLoading,
          ),
          SizedBox(
            height: 15.w,
          ),
          // Show retry button if there was an error
          if (state.error)
            RetryErrorMessage(
              isDarkMode: widget.isDarkMode,
              errorMessage: 'Failed to load counts :(',
              buttonFunctionality: () async {
                ref
                    .read(manageMyNetworkScreenViewModelProvider.notifier)
                    .getManageMyNetworkScreenCounts();
              },
            ),
        ],
      ),
    );
  }
}

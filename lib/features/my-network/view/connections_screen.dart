import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';
import 'package:link_up/features/my-network/viewModel/manage_my_network_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/connections_card.dart';
import 'package:link_up/features/my-network/widgets/connections_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  final int paginationLimit;

  const ConnectionsScreen({
    super.key,
    this.paginationLimit = 10,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  int _selectedSortOption = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(connectionsScreenViewModelProvider.notifier)
          .getConnectionsCount();
    });

    Future.microtask(
      () {
        ref
            .read(connectionsScreenViewModelProvider.notifier)
            .getConnectionsList(
          {
            'limit': '${widget.paginationLimit}',
            'cursor': null,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(connectionsScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Connections',
          style: TextStyles.font20_500Weight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25.w,
            color: isDarkMode
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(manageMyNetworkScreenViewModelProvider.notifier)
                .getManageMyNetworkScreenCounts();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
            ),
          ),
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
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.isLoading)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightSecondaryText,
                      ),
                    )
                  else if (state.connectionsCount != null)
                    Text(
                      '${parseIntegerToCommaSeparatedString(state.connectionsCount ?? 0)} connections',
                      style: TextStyles.font18_500Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => {},
                        icon: Icon(
                          Icons.search,
                          size: 25.r,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5.h,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? AppColors.darkMain
                                        : AppColors.lightMain,
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1.w,
                                        color: isDarkMode
                                            ? AppColors.darkGrey
                                            : AppColors.lightGrey,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 20.w,
                                    ),
                                    child: Text(
                                      'Sort By',
                                      style:
                                          TextStyles.font18_500Weight.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: [
                                      // Newest First
                                      FilterChip(
                                        selected: _selectedSortOption == 0,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkMain
                                            : AppColors.lightMain,
                                        selectedColor: isDarkMode
                                            ? AppColors.darkGreen
                                            : AppColors.lightGreen,
                                        label: Text(
                                          'Recently added',
                                          style: TextStyles.font14_500Weight
                                              .copyWith(
                                                  color: _selectedSortOption ==
                                                          0
                                                      ? isDarkMode
                                                          ? AppColors
                                                              .darkBackground
                                                          : AppColors
                                                              .lightBackground
                                                      : isDarkMode
                                                          ? AppColors
                                                              .darkTextColor
                                                          : AppColors
                                                              .lightSecondaryText),
                                        ),
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedSortOption = 0;
                                            });
                                            ref
                                                .read(
                                                    connectionsScreenViewModelProvider
                                                        .notifier)
                                                .sortConnections(0);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),

                                      // Oldest First
                                      FilterChip(
                                        selected: _selectedSortOption == 1,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkMain
                                            : AppColors.lightMain,
                                        selectedColor: isDarkMode
                                            ? AppColors.darkGreen
                                            : AppColors.lightGreen,
                                        label: Text(
                                          'Firstly added',
                                          style: TextStyles.font14_500Weight
                                              .copyWith(
                                            color: _selectedSortOption == 1
                                                ? isDarkMode
                                                    ? AppColors.darkBackground
                                                    : AppColors.lightBackground
                                                : isDarkMode
                                                    ? AppColors.darkTextColor
                                                    : AppColors
                                                        .lightSecondaryText,
                                          ),
                                        ),
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedSortOption = 1;
                                            });
                                            ref
                                                .read(
                                                    connectionsScreenViewModelProvider
                                                        .notifier)
                                                .sortConnections(1);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),

                                      // Name A-Z
                                      FilterChip(
                                        selected: _selectedSortOption == 2,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkMain
                                            : AppColors.lightMain,
                                        selectedColor: isDarkMode
                                            ? AppColors.darkGreen
                                            : AppColors.lightGreen,
                                        label: Text(
                                          'Name (A-Z)',
                                          style: TextStyles.font14_500Weight
                                              .copyWith(
                                            color: _selectedSortOption == 2
                                                ? isDarkMode
                                                    ? AppColors.darkBackground
                                                    : AppColors.lightBackground
                                                : isDarkMode
                                                    ? AppColors.darkTextColor
                                                    : AppColors
                                                        .lightSecondaryText,
                                          ),
                                        ),
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedSortOption = 2;
                                            });
                                            ref
                                                .read(
                                                    connectionsScreenViewModelProvider
                                                        .notifier)
                                                .sortConnections(2);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),

                                      // Name Z-A
                                      FilterChip(
                                        selected: _selectedSortOption == 3,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkMain
                                            : AppColors.lightMain,
                                        selectedColor: isDarkMode
                                            ? AppColors.darkGreen
                                            : AppColors.lightGreen,
                                        label: Text(
                                          'Name (Z-A)',
                                          style: TextStyles.font14_500Weight
                                              .copyWith(
                                            color: _selectedSortOption == 3
                                                ? isDarkMode
                                                    ? AppColors.darkBackground
                                                    : AppColors.lightBackground
                                                : isDarkMode
                                                    ? AppColors.darkTextColor
                                                    : AppColors
                                                        .lightSecondaryText,
                                          ),
                                        ),
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedSortOption = 3;
                                            });
                                            ref
                                                .read(
                                                    connectionsScreenViewModelProvider
                                                        .notifier)
                                                .sortConnections(3);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.tune,
                          size: 25.r,
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                ref
                    .read(connectionsScreenViewModelProvider.notifier)
                    .loadMoreConnections(
                        paginationLimit: widget.paginationLimit);
              }
              return false;
            },
            child: Expanded(
              child: state.isLoading && state.connections == null
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) =>
                          ConnectionsCardLoadingSkeleton(
                              isDarkMode: isDarkMode),
                    )
                  : state.isError
                      ? RetryErrorMessage(
                          isDarkMode: isDarkMode,
                          errorMessage: "Failed to load connections :(",
                          buttonFunctionality: () async {
                            await ref
                                .read(
                                    connectionsScreenViewModelProvider.notifier)
                                .getConnectionsList(
                              {
                                'limit': '${widget.paginationLimit}',
                                'cursor': null,
                              },
                            );
                          },
                        )
                      : state.connections == null || state.connections!.isEmpty
                          ? StandardEmptyListMessage(
                              isDarkMode: isDarkMode, message: 'No connections')
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.connections!.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.connections!.length) {
                                  // Show loading indicator at the bottom when loading more
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: isDarkMode
                                            ? AppColors.darkBlue
                                            : AppColors.lightBlue,
                                      ),
                                    ),
                                  );
                                }
                                return ConnectionsCard(
                                  data: state.connections![index],
                                  isDarkMode: isDarkMode,
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

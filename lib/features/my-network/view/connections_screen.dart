import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/connections_card.dart';
import 'package:link_up/features/my-network/widgets/connections_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final int paginationLimit;

  const ConnectionsScreen({
    super.key,
    required this.isDarkMode,
    this.paginationLimit = 10,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
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
    final state = ref.watch(connectionsScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Connections',
          style: TextStyles.font20_700Weight.copyWith(
            color: widget.isDarkMode
                ? AppColors.darkTextColor
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
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${parseIntegerToCommaSeparatedString(state.connectionsCount ?? 0)} connections',
                    style: TextStyles.font18_500Weight.copyWith(
                      color: widget.isDarkMode
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
                          color: widget.isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => {},
                        icon: Icon(
                          Icons.tune,
                          size: 25.r,
                          color: widget.isDarkMode
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
                          ConnectionsLoadingSkeleton(
                              isDarkMode: widget.isDarkMode),
                    )
                  : state.isError
                      ? RetryErrorMessage(
                          isDarkMode: widget.isDarkMode,
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
                              isDarkMode: widget.isDarkMode,
                              message: 'No connections')
                          : RefreshIndicator(
                              color: Colors.white,
                              backgroundColor: widget.isDarkMode
                                  ? AppColors.darkBlue
                                  : AppColors.lightBlue,
                              onRefresh: () async {
                                await ref
                                    .read(connectionsScreenViewModelProvider
                                        .notifier)
                                    .getConnectionsList(
                                  {
                                    'limit': '${widget.paginationLimit}',
                                    'cursor': null,
                                  },
                                );
                              },
                              child: ListView.builder(
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
                                          color: widget.isDarkMode
                                              ? AppColors.darkBlue
                                              : AppColors.lightBlue,
                                        ),
                                      ),
                                    );
                                  }

                                  return ConnectionsCard(
                                    data: state.connections![index],
                                    isDarkMode: widget.isDarkMode,
                                  );
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

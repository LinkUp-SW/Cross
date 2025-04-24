import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/viewModel/received_invitations_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';

class ReceivedInvitationsTab extends ConsumerStatefulWidget {
  final int paginationLimit;

  const ReceivedInvitationsTab({
    super.key,
    this.paginationLimit = 10,
  });

  @override
  ConsumerState<ReceivedInvitationsTab> createState() =>
      _ReceivedInvitationsTabState();
}

class _ReceivedInvitationsTabState
    extends ConsumerState<ReceivedInvitationsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref
            .read(receivedInvitationsTabViewModelProvider.notifier)
            .getReceivedInvitations(
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
    final state = ref.watch(receivedInvitationsTabViewModelProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref
              .read(receivedInvitationsTabViewModelProvider.notifier)
              .loadMoreReceivedInvitations(
                paginationLimit: widget.paginationLimit,
              );
        }
        return false;
      },
      child: state.isLoading && state.received == null
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) =>
                  ReceivedInvitationsCardLoadingSkeleton(),
            )
          : state.error
              ? RetryErrorMessage(
                  isDarkMode: isDarkMode,
                  errorMessage:
                      "Failed to load received connection invitations :(",
                  buttonFunctionality: () async {
                    await ref
                        .read(receivedInvitationsTabViewModelProvider.notifier)
                        .getReceivedInvitations(
                      {
                        'limit': '${widget.paginationLimit}',
                        'cursor': null,
                      },
                    );
                  },
                )
              : state.received == null || state.received!.isEmpty
                  ? StandardEmptyListMessage(
                      isDarkMode: isDarkMode,
                      message: 'No received connection invitations',
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.received!.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.received!.length) {
                          // Show loading indicator at the bottom when loading more
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: isDarkMode
                                    ? AppColors.darkBlue
                                    : AppColors.lightBlue,
                              ),
                            ),
                          );
                        }
                        return ReceivedInvitationsCard(
                          data: state.received![index],
                          onAccept: (userId) {
                            ref
                                .read(receivedInvitationsTabViewModelProvider
                                    .notifier)
                                .acceptInvitation(userId);
                          },
                          onIgnore: (userId) {
                            ref
                                .read(receivedInvitationsTabViewModelProvider
                                    .notifier)
                                .ignoreInvitation(userId);
                          },
                        );
                      },
                    ),
    );
  }
}

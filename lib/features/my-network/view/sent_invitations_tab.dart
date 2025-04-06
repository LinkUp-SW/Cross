import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/viewModel/sent_invitations_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/sent_invitation_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/sent_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';

class SentInvitationsTab extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final int paginationLimit;

  const SentInvitationsTab({
    super.key,
    required this.isDarkMode,
    this.paginationLimit = 10,
  });

  @override
  ConsumerState<SentInvitationsTab> createState() => _SentInvitationsTabState();
}

class _SentInvitationsTabState extends ConsumerState<SentInvitationsTab> {
  @override
  void initState() {
    super.initState();
    // Load data when the tab is created
    Future.microtask(
      () {
        ref
            .read(sentInvitationsTabViewModelProvider.notifier)
            .getSentInvitations(
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
    final state = ref.watch(sentInvitationsTabViewModelProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref
              .read(sentInvitationsTabViewModelProvider.notifier)
              .loadMoreSentInvitations(
                paginationLimit: widget.paginationLimit,
              );
        }
        return false;
      },
      child: state.isLoading && state.sent == null
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) => SentInvitationsLoadingSkeleton(
                isDarkMode: widget.isDarkMode,
              ),
            )
          : state.error
              ? RetryErrorMessage(
                  isDarkMode: widget.isDarkMode,
                  errorMessage: "Failed to load sent connection invitations :(",
                  buttonFunctionality: () async {
                    await ref
                        .read(sentInvitationsTabViewModelProvider.notifier)
                        .getSentInvitations(
                      {
                        'limit': '${widget.paginationLimit}',
                        'cursor': null,
                      },
                    );
                  },
                )
              : state.sent == null || state.sent!.isEmpty
                  ? StandardEmptyListMessage(
                      isDarkMode: widget.isDarkMode,
                      message: 'No sent connection invitations',
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          state.sent!.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.sent!.length) {
                          // Show loading indicator at the bottom when loading more
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: widget.isDarkMode
                                    ? AppColors.darkBlue
                                    : AppColors.lightBlue,
                              ),
                            ),
                          );
                        }
                        return SentInvitationsCard(
                          data: state.sent![index],
                          isDarkMode: widget.isDarkMode,
                        );
                      },
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/viewModel/sent_invitations_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/sent_invitation_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/sent_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';

class SentInvitationsTab extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const SentInvitationsTab({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<SentInvitationsTab> createState() => _SentInvitationsTabState();
}

class _SentInvitationsTabState extends ConsumerState<SentInvitationsTab> {
  @override
  void initState() {
    super.initState();
    // Load data when the tab is created
    Future.microtask(() {
      ref
          .read(sentInvitationsTabViewModelProvider.notifier)
          .getSentInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for state changes
    final state = ref.watch(sentInvitationsTabViewModelProvider);

    if (state.isLoading && state.sent == null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) =>
            SentInvitationsLoadingSkeleton(isDarkMode: widget.isDarkMode),
      );
    } else if (state.error) {
      return RetryErrorMessage(
        isDarkMode: widget.isDarkMode,
        errorMessage: "Failed to load sent connection invitations :(",
        buttonFunctionality: () async {
          await ref
              .read(sentInvitationsTabViewModelProvider.notifier)
              .getSentInvitations();
        },
      );
    } else if (state.sent == null || state.sent!.isEmpty) {
      return StandardEmptyListMessage(
          isDarkMode: widget.isDarkMode,
          message: 'No sent connection invitations');
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor:
          widget.isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
      onRefresh: () async {
        await ref
            .read(sentInvitationsTabViewModelProvider.notifier)
            .getSentInvitations();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.sent!.length,
        itemBuilder: (context, index) {
          return SentInvitationsCard(
            data: state.sent![index],
            isDarkMode: widget.isDarkMode,
          );
        },
      ),
    );
  }
}

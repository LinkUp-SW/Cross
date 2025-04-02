import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/viewModel/invitations_screen_view_model.dart';
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
          .read(invitationsScreenViewModelProvider.notifier)
          .getSentInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for state changes
    final state = ref.watch(invitationsScreenViewModelProvider);

    if (state.isLoading && state.received == null) {
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
              .read(invitationsScreenViewModelProvider.notifier)
              .getSentInvitations();
        },
      );
    } else if (state.received == null || state.received!.isEmpty) {
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
            .read(invitationsScreenViewModelProvider.notifier)
            .getReceivedInvitations();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.received!.length,
        itemBuilder: (context, index) {
          return SentInvitationsCard(
            data: state.received![index],
            isDarkMode: widget.isDarkMode,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/viewModel/invitations_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';

class ReceivedInvitationsTab extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const ReceivedInvitationsTab({
    super.key,
    required this.isDarkMode,
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
    Future.microtask(() {
      ref
          .read(invitationsScreenViewModelProvider.notifier)
          .getReceivedInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invitationsScreenViewModelProvider);

    if (state.isLoading && state.received == null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) =>
            ReceivedInvitationsLoadingSkeleton(isDarkMode: widget.isDarkMode),
      );
    } else if (state.error) {
      return RetryErrorMessage(
        isDarkMode: widget.isDarkMode,
        errorMessage: "Failed to load received connection invitations :(",
        buttonFunctionality: () async {
          await ref
              .read(invitationsScreenViewModelProvider.notifier)
              .getReceivedInvitations();
        },
      );
    } else if (state.received == null || state.received!.isEmpty) {
      return StandardEmptyListMessage(
          isDarkMode: widget.isDarkMode,
          message: 'No received connection invitations');
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
          return ReceivedInvitationsCard(
            data: state.received![index],
            isDarkMode: widget.isDarkMode,
          );
        },
      ),
    );
  }
}

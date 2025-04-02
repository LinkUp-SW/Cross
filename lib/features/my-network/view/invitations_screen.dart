import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/state/invitations_screen_state.dart';
import 'package:link_up/features/my-network/viewModel/invitations_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/sent_invitation_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/sent_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class InvitationsScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const InvitationsScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends ConsumerState<InvitationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch both received and sent invitations when the screen loads
    Future.microtask(() {
      ref
          .read(invitationsScreenViewModelProvider.notifier)
          .getReceivedInvitations();
      ref
          .read(invitationsScreenViewModelProvider.notifier)
          .getSentInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the invitations state
    final invitationsState = ref.watch(invitationsScreenViewModelProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Invitations',
            style: TextStyles.font20_700Weight.copyWith(
              color: widget.isDarkMode
                  ? AppColors.darkGrey
                  : AppColors.lightTextColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: EdgeInsets.symmetric(horizontal: 15.w),
                labelStyle: TextStyles.font13_500Weight,
                unselectedLabelStyle: TextStyles.font13_500Weight,
                labelColor: widget.isDarkMode
                    ? AppColors.darkGreen
                    : AppColors.lightGreen,
                unselectedLabelColor: widget.isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
                tabs: const [
                  Tab(text: "Received"),
                  Tab(text: "Sent"),
                ],
              ),
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
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                color: widget.isDarkMode
                    ? AppColors.darkGrey
                    : AppColors.lightTextColor,
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            _buildReceivedInvitationsTab(invitationsState, widget.isDarkMode),
            _buildSentInvitationsTab(invitationsState, widget.isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedInvitationsTab(
      InvitationsScreenState state, bool isDarkMode) {
    if (state.isLoading && state.received == null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) =>
            ReceivedInvitationsLoadingSkeleton(isDarkMode: isDarkMode),
      );
    } else if (state.error) {
      return RetryErrorMessage(
        isDarkMode: isDarkMode,
        errorMessage: "Failed to load received connection invitations :(",
        buttonFunctionality: () async {
          await ref
              .read(invitationsScreenViewModelProvider.notifier)
              .getReceivedInvitations();
        },
      );
    } else if (state.received == null || state.received!.isEmpty) {
      return StandardEmptyListMessage(
          isDarkMode: isDarkMode,
          message: 'No received connection invitations');
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(invitationsScreenViewModelProvider.notifier)
              .getReceivedInvitations();
        },
        child: ListView.builder(
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

  Widget _buildSentInvitationsTab(
      InvitationsScreenState state, bool isDarkMode) {
    if (state.isLoading && state.sent == null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) =>
            SentInvitationsLoadingSkeleton(isDarkMode: isDarkMode),
      );
    } else if (state.error) {
      return RetryErrorMessage(
        isDarkMode: isDarkMode,
        errorMessage: "Failed to load sent connection invitations :(",
        buttonFunctionality: () async {
          await ref
              .read(invitationsScreenViewModelProvider.notifier)
              .getSentInvitations();
        },
      );
    } else if (state.sent == null || state.sent!.isEmpty) {
      return StandardEmptyListMessage(
          isDarkMode: isDarkMode, message: 'No sent connection invitations');
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(invitationsScreenViewModelProvider.notifier)
              .getSentInvitations();
        },
        child: ListView.builder(
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
}

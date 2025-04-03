import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/sent_invitations_tab_services.dart';
import 'package:link_up/features/my-network/state/sent_invitations_tab_state.dart';

class SentInvitationsTabViewModel
    extends StateNotifier<SentInvitationsTabState> {
  final SentInvitationsTabServices _sentInvitationsTabServices;

  SentInvitationsTabViewModel(this._sentInvitationsTabServices)
      : super(SentInvitationsTabState.initial());

  // Fetch sent invitations
  Future<void> getSentInvitations() async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response = await _sentInvitationsTabServices.getSentInvitations();

      // Parse the sent invitations from the response
      final List<InvitationsCardModel> sentInvitations =
          (response['sentConnections'] as List)
              .map((invitation) => InvitationsCardModel.fromJson(invitation))
              .toList();
      state = state.copyWith(isLoading: false, sent: sentInvitations);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  Future<void> loadMoreSentInvitations({required int paginationLimit}) async {
    final currentState = state;

    // Don't load if we're already loading or at the end
    if (currentState.isLoadingMore || currentState.nextCursor == null) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final response = await _sentInvitationsTabServices.getSentInvitations(
        queryParameters: {
          'limit': '$paginationLimit',
          'cursor': currentState.nextCursor,
        },
      );

      final newSentInviations = (response['sentConnections'] as List)
          .map((c) => InvitationsCardModel.fromJson(c))
          .toList();

      final List<InvitationsCardModel> allSentInvitaions = [
        ...currentState.sent ?? [],
        ...newSentInviations
      ];

      state = currentState.copyWith(
        sent: allSentInvitaions,
        nextCursor: response['nextCursor'],
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(isLoadingMore: false);
    }
  }

  // Withdraw an invitation
  Future<void> withdrawInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await _sentInvitationsTabServices.withdrawInvitation(userId);
      // Remove the withdrawn invitation from the sent list
      if (state.sent != null) {
        final updatedInvitations = state.sent!
            .where((invitation) => invitation.cardId != userId)
            .toList();

        state = state.copyWith(isLoading: false, sent: updatedInvitations);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }
}

// Provider for the view model
final sentInvitationsTabViewModelProvider =
    StateNotifierProvider<SentInvitationsTabViewModel, SentInvitationsTabState>(
  (ref) {
    return SentInvitationsTabViewModel(
      ref.read(sentInvitationsTabServicesProvider),
    );
  },
);

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
  Future<void> getSentInvitations(Map<String, dynamic>? queryParameters) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response = await _sentInvitationsTabServices.getSentInvitations(
        queryParameters: queryParameters,
      );

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

      final List<dynamic> sentData = response['sentConnections'] as List? ?? [];
      // If server returns empty data, we've reached the end
      if (sentData.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final newSentInvitations =
          sentData.map((c) => InvitationsCardModel.fromJson(c)).toList();

      // Check for duplicates using cardId
      final existingIds = currentState.sent?.map((c) => c.cardId).toSet() ?? {};
      final uniqueNewInvitations = newSentInvitations
          .where((invitation) => !existingIds.contains(invitation.cardId))
          .toList();

      // If we got no unique results despite getting data, we're at the end
      if (uniqueNewInvitations.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final List<InvitationsCardModel> allSentInvitations = [
        ...currentState.sent ?? [],
        ...uniqueNewInvitations
      ];

      state = currentState.copyWith(
        sent: allSentInvitations,
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

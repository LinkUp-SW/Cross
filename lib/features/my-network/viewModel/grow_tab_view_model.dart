import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/grow_tab_services.dart';
import 'package:link_up/features/my-network/state/grow_tab_state.dart';

class GrowTabViewModel extends Notifier<GrowTabState> {
  @override
  GrowTabState build() {
    return GrowTabState.initial();
  }

  // Fetch received invitations
  Future<void> getReceivedInvitations(
      {Map<String, dynamic>? queryParameters}) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response =
          await ref.read(growTabServicesProvider).getReceivedInvitations(
                queryParameters: queryParameters,
              );

      // Parse the received invitations from the response
      final List<InvitationsCardModel> receivedInvitations =
          (response['receivedConnections'] as List)
              .map((invitation) => InvitationsCardModel.fromJson(invitation))
              .toList();
      state = state.copyWith(
        isLoading: false,
        receivedInvitations: receivedInvitations,
        receivedInvitationsCount: receivedInvitations.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  // Accept an invitation
  Future<void> acceptInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await ref.read(growTabServicesProvider).acceptInvitation(userId);

      // Remove the accepted invitation from the received list
      if (state.receivedInvitations != null) {
        final updatedInvitations = state.receivedInvitations!
            .where((invitation) => invitation.cardId != userId)
            .toList();

        state = state.copyWith(
          isLoading: false,
          receivedInvitations: updatedInvitations,
          receivedInvitationsCount: updatedInvitations.length,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  // Ignore an invitation
  Future<void> ignoreInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await ref.read(growTabServicesProvider).ignoreInvitation(userId);

      // Remove the ignored invitation from the received list
      if (state.receivedInvitations != null) {
        final updatedInvitations = state.receivedInvitations!
            .where((invitation) => invitation.cardId != userId)
            .toList();

        state = state.copyWith(
          isLoading: false,
          receivedInvitations: updatedInvitations,
          receivedInvitationsCount: updatedInvitations.length,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }
}

final growTabViewModelProvider =
    NotifierProvider<GrowTabViewModel, GrowTabState>(
  () {
    return GrowTabViewModel();
  },
);

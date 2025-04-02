import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/received_invitations_tab_services.dart';
import 'package:link_up/features/my-network/state/received_invitations_tab_state.dart';

class ReceivedInvitationsTabViewModel
    extends StateNotifier<ReceivedInvitationsTabState> {
  final ReceivedInvitationsTabServices _receivedInvitationsTabServices;

  ReceivedInvitationsTabViewModel(this._receivedInvitationsTabServices)
      : super(ReceivedInvitationsTabState.initial());

  // Fetch received invitations
  Future<void> getReceivedInvitations() async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response =
          await _receivedInvitationsTabServices.getReceivedInvitations();

      // Parse the received invitations from the response
      final List<InvitationsCardModel> receivedInvitations =
          (response['receivedConnections'] as List)
              .map((invitation) => InvitationsCardModel.fromJson(invitation))
              .toList();
      state = state.copyWith(isLoading: false, received: receivedInvitations);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  // Accept an invitation
  Future<void> acceptInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await _receivedInvitationsTabServices.acceptInvitation(userId);

      // Remove the accepted invitation from the received list
      if (state.received != null) {
        final updatedInvitations = state.received!
            .where((invitation) => invitation.cardId != userId)
            .toList();

        state = state.copyWith(isLoading: false, received: updatedInvitations);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  // Ignore an invitation
  Future<void> ignoreInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await _receivedInvitationsTabServices.ignoreInvitation(userId);

      // Remove the ignored invitation from the received list
      if (state.received != null) {
        final updatedInvitations = state.received!
            .where((invitation) => invitation.cardId != userId)
            .toList();

        state = state.copyWith(isLoading: false, received: updatedInvitations);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: true);
    }
  }
}

// Provider for the view model
final receivedInvitationsTabViewModelProvider = StateNotifierProvider<
    ReceivedInvitationsTabViewModel, ReceivedInvitationsTabState>((ref) {
  return ReceivedInvitationsTabViewModel(
      ref.read(receivedInvitationsTabServicesProvider));
});

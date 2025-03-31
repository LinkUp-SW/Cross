import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/invitations_screen_services.dart';
import 'package:link_up/features/my-network/state/invitations_screen_state.dart';

class InvitationsScreenViewModel extends StateNotifier<InvitationsScreenState> {
  final InvitationsScreenServices _invitationsScreenServices;

  InvitationsScreenViewModel(this._invitationsScreenServices)
      : super(InvitationsScreenState.initial());

  // Fetch received invitations
  Future<void> getReceivedInvitations() async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response =
          await _invitationsScreenServices.getReceivedInvitations();

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

  // Fetch sent invitations
  Future<void> getSentInvitations() async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response = await _invitationsScreenServices.getSentInvitations();

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

  // Accept an invitation
  Future<void> acceptInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      await _invitationsScreenServices.acceptInvitation(userId);

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
      await _invitationsScreenServices.ignoreInvitation(userId);

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

  // Withdraw an invitation
  Future<void> withdrawInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final withdrawResponse =
          await _invitationsScreenServices.withdrawInvitation(userId);
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
final invitationsScreenViewModelProvider =
    StateNotifierProvider<InvitationsScreenViewModel, InvitationsScreenState>(
        (ref) {
  return InvitationsScreenViewModel(
      ref.read(invitationsScreenServicesProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/received_invitations_tab_services.dart';
import 'package:link_up/features/my-network/state/received_invitations_tab_state.dart';

class ReceivedInvitationsTabViewModel
<<<<<<< HEAD
    extends Notifier<ReceivedInvitationsTabState> {
  @override
  ReceivedInvitationsTabState build() {
    return ReceivedInvitationsTabState.initial();
  }

  // Fetch received invitations
  Future<void> getReceivedInvitations(
      {Map<String, dynamic>? queryParameters}) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response = await ref
          .read(receivedInvitationsTabServicesProvider)
          .getReceivedInvitations(
            queryParameters: queryParameters,
          );
=======
    extends StateNotifier<ReceivedInvitationsTabState> {
  final ReceivedInvitationsTabServices _receivedInvitationsTabServices;

  ReceivedInvitationsTabViewModel(this._receivedInvitationsTabServices)
      : super(ReceivedInvitationsTabState.initial());

  // Fetch received invitations
  Future<void> getReceivedInvitations(
      Map<String, dynamic>? queryParameters) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response =
          await _receivedInvitationsTabServices.getReceivedInvitations(
        queryParameters: queryParameters,
      );
>>>>>>> feature/jobss

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

<<<<<<< HEAD
  Future<void> loadMoreReceivedInvitations(int paginationLimit) async {
=======
  Future<void> loadMoreReceivedInvitations(
      {required int paginationLimit}) async {
>>>>>>> feature/jobss
    final currentState = state;

    // Don't load if we're already loading or at the end
    if (currentState.isLoadingMore || currentState.nextCursor == null) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
<<<<<<< HEAD
      final response = await ref
          .read(receivedInvitationsTabServicesProvider)
          .getReceivedInvitations(
=======
      final response =
          await _receivedInvitationsTabServices.getReceivedInvitations(
>>>>>>> feature/jobss
        queryParameters: {
          'limit': '$paginationLimit',
          'cursor': currentState.nextCursor,
        },
      );

      final List<dynamic> receivedData =
          response['receivedConnections'] as List? ?? [];
      // If server returns empty data, we've reached the end
      if (receivedData.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final newReceivedInvitations =
          receivedData.map((c) => InvitationsCardModel.fromJson(c)).toList();

      // Check for duplicates using cardId
      final existingIds =
          currentState.received?.map((c) => c.cardId).toSet() ?? {};
      final uniqueNewInvitations = newReceivedInvitations
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

      final List<InvitationsCardModel> allReceivedInvitations = [
        ...currentState.received ?? [],
        ...uniqueNewInvitations
      ];

      state = currentState.copyWith(
        received: allReceivedInvitations,
        nextCursor: response['nextCursor'],
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(isLoadingMore: false);
    }
  }

  // Accept an invitation
  Future<void> acceptInvitation(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
<<<<<<< HEAD
      await ref
          .read(receivedInvitationsTabServicesProvider)
          .acceptInvitation(userId);
=======
      await _receivedInvitationsTabServices.acceptInvitation(userId);
>>>>>>> feature/jobss

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
<<<<<<< HEAD
      await ref
          .read(receivedInvitationsTabServicesProvider)
          .ignoreInvitation(userId);
=======
      await _receivedInvitationsTabServices.ignoreInvitation(userId);
>>>>>>> feature/jobss

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
<<<<<<< HEAD
final receivedInvitationsTabViewModelProvider = NotifierProvider<
    ReceivedInvitationsTabViewModel, ReceivedInvitationsTabState>(() {
  return ReceivedInvitationsTabViewModel();
=======
final receivedInvitationsTabViewModelProvider = StateNotifierProvider<
    ReceivedInvitationsTabViewModel, ReceivedInvitationsTabState>((ref) {
  return ReceivedInvitationsTabViewModel(
      ref.read(receivedInvitationsTabServicesProvider));
>>>>>>> feature/jobss
});

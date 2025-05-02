import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/people_card_model.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';
import 'package:link_up/features/my-network/services/grow_tab_services.dart';
import 'package:link_up/features/my-network/state/grow_tab_state.dart';
import 'dart:developer';

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
      final Set<InvitationsCardModel> receivedInvitations =
          (response['receivedConnections'] as List)
              .map((invitation) => InvitationsCardModel.fromJson(invitation))
              .toSet();
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
            .toSet();

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
            .toSet();

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

  Future<void> getPeopleYouMayKnow(
      {Map<String, dynamic>? queryParameters}) async {
    try {
      state = state.copyWith(isLoading: true, error: false);
      final response =
          await ref.read(growTabServicesProvider).getPeopleYouMayKnow(
                queryParameters: queryParameters,
              );
      if (queryParameters!['context'] == 'education') {
        // Parse the received invitations from the response
        final Set<PeopleCardsModel> peopleYouMayKnowFromEducation =
            (response['people'] as List)
                .map((person) => PeopleCardsModel.fromJson(person))
                .toSet();
        state = state.copyWith(
            isLoading: false,
            peopleYouMayKnowFromEducation: peopleYouMayKnowFromEducation,
            educationTitle: peopleYouMayKnowFromEducation.isNotEmpty
                ? response['institutionName']
                : null,
            educationNextCursor: response['nextCursor']); // Add this
      } else {
        // Parse the received invitations from the response
        final Set<PeopleCardsModel> peopleYouMayKnowFromWork =
            (response['people'] as List)
                .map((person) => PeopleCardsModel.fromJson(person))
                .toSet();
        state = state.copyWith(
            isLoading: false,
            peopleYouMayKnowFromWork: peopleYouMayKnowFromWork,
            workTitle: peopleYouMayKnowFromWork.isNotEmpty
                ? response['institutionName']
                : null,
            workNextCursor: response['nextCursor']); // Add this
      }
    } catch (e) {
      log("Error in getPeopleYouMayKnow: $e");
      state = state.copyWith(isLoading: false, error: true);
    }
  }

  // Withdraw an invitation
  Future<void> withdrawInvitation(String userId) async {
    try {
      await ref.read(growTabServicesProvider).withdrawInvitation(userId);
    } catch (e) {
      log('Error withdrawing connection request: $e');
    }
  }

  Future<void> sendConnectionRequest(
    String userId, {
    Map<String, dynamic>? body,
  }) async {
    try {
      await ref
          .read(growTabServicesProvider)
          .sendConnectionRequest(userId, body: body);
    } catch (e) {
      log('Error sending connection request: $e');
    }
  }

  Future<bool> getReplacementPerson(String cardId, String context) async {
    try {
      final response =
          await ref.read(growTabServicesProvider).getPeopleYouMayKnow(
        queryParameters: {
          "cursor": context == 'education'
              ? state.educationNextCursor
              : state.workNextCursor,
          "limit": "1",
          "context": context,
        },
      );

      if (response['nextCursor'] != null) {
        final newPerson = PeopleCardsModel.fromJson(response['people'][0]);

        // Check if this person already exists in our list
        bool isDuplicate = false;
        if (context == 'education') {
          isDuplicate = state.peopleYouMayKnowFromEducation!.any((person) =>
              person.cardId == newPerson.cardId && person.cardId != cardId);
        } else {
          isDuplicate = state.peopleYouMayKnowFromWork!.any((person) =>
              person.cardId == newPerson.cardId && person.cardId != cardId);
        }

        if (isDuplicate) {
          log("Duplicate person found, no more unique recommendations");
          return false;
        }

        // Update the appropriate list based on context
        if (context == 'education') {
          // Your existing code for education list updates
          final updatedList = [...state.peopleYouMayKnowFromEducation!];
          final index =
              updatedList.indexWhere((person) => person.cardId == cardId);
          if (index != -1) {
            updatedList[index] = newPerson;
          }

          state = state.copyWith(
            peopleYouMayKnowFromEducation: updatedList.toSet(),
            educationNextCursor: response['nextCursor'],
          );
        } else {
          // Your existing code for work list updates
        }

        log("Replaced card $cardId with new person");
        return true;
      } else {
        // No replacement available - refresh the entire list
        await getPeopleYouMayKnow(
          queryParameters: {
            "cursor": null,
            "limit": "4",
            "context": context,
          },
        );
        log("No replacement found, refreshed the entire list");
        return false;
      }
    } catch (e) {
      log("Error fetching replacement person: $e");
      return false;
    }
  }
}

final growTabViewModelProvider =
    NotifierProvider<GrowTabViewModel, GrowTabState>(
  () {
    return GrowTabViewModel();
  },
);

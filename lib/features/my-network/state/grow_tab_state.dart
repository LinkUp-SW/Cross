import 'package:link_up/features/my-network/model/people_card_model.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class GrowTabState {
  final bool isLoading;
  final bool error;
  final String? educationTitle;
  final String? workTitle;
  final String? educationNextCursor;
  final String? workNextCursor;
  final Set<PeopleCardsModel>? peopleYouMayKnowFromEducation;
  final Set<PeopleCardsModel>? peopleYouMayKnowFromWork;
  final Set<InvitationsCardModel>? receivedInvitations;
  final int? receivedInvitationsCount;

  GrowTabState({
    this.isLoading = false,
    this.error = false,
    this.educationTitle,
    this.workTitle,
    this.educationNextCursor,
    this.workNextCursor,
    this.peopleYouMayKnowFromEducation,
    this.peopleYouMayKnowFromWork,
    this.receivedInvitations,
    this.receivedInvitationsCount,
  });

  factory GrowTabState.initial() {
    return GrowTabState(
      educationTitle: null,
      workTitle: null,
      peopleYouMayKnowFromWork: null,
      peopleYouMayKnowFromEducation: null,
      receivedInvitations: null,
      receivedInvitationsCount: null,
      isLoading: true,
      error: false,
    );
  }

  // Update copyWith
  GrowTabState copyWith({
    bool? isLoading,
    bool? error,
    String? educationTitle,
    String? workTitle,
    String? educationNextCursor,
    String? workNextCursor,
    Set<PeopleCardsModel>? peopleYouMayKnowFromEducation,
    Set<PeopleCardsModel>? peopleYouMayKnowFromWork,
    Set<InvitationsCardModel>? receivedInvitations,
    int? receivedInvitationsCount,
  }) {
    return GrowTabState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      educationTitle: educationTitle ?? this.educationTitle,
      workTitle: workTitle ?? this.workTitle,
      educationNextCursor: educationNextCursor ?? this.educationNextCursor,
      workNextCursor: workNextCursor ?? this.workNextCursor,
      peopleYouMayKnowFromEducation:
          peopleYouMayKnowFromEducation ?? this.peopleYouMayKnowFromEducation,
      peopleYouMayKnowFromWork:
          peopleYouMayKnowFromWork ?? this.peopleYouMayKnowFromWork,
      receivedInvitations: receivedInvitations ?? this.receivedInvitations,
      receivedInvitationsCount:
          receivedInvitationsCount ?? this.receivedInvitationsCount,
    );
  }
}

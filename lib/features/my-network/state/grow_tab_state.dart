import 'package:link_up/features/my-network/model/people_card_model.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class GrowTabState {
  final String? educationTitle;
  final String? workTitle;
  final List<PeopleCardsModel>? peopleYouMayKnowFromWork;
  final List<PeopleCardsModel>? peopleYouMayKnowFromEducation;
  final List<InvitationsCardModel>? receivedInvitations;
  final int? receivedInvitationsCount;
  final bool isLoading;
  final bool error;

  const GrowTabState({
    this.educationTitle,
    this.workTitle,
    this.peopleYouMayKnowFromWork,
    this.peopleYouMayKnowFromEducation,
    this.receivedInvitations,
    this.receivedInvitationsCount,
    required this.isLoading,
    required this.error,
  });

  factory GrowTabState.initial() {
    return const GrowTabState(
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

  GrowTabState copyWith({
    String? educationTitle,
    String? workTitle,
    List<PeopleCardsModel>? peopleYouMayKnowFromWork,
    List<PeopleCardsModel>? peopleYouMayKnowFromEducation,
    List<InvitationsCardModel>? receivedInvitations,
    int? receivedInvitationsCount,
    bool? isLoading,
    bool? error,
  }) {
    return GrowTabState(
      workTitle: workTitle ?? this.workTitle,
      educationTitle: educationTitle ?? this.educationTitle,
      peopleYouMayKnowFromWork:
          peopleYouMayKnowFromWork ?? this.peopleYouMayKnowFromWork,
      peopleYouMayKnowFromEducation:
          peopleYouMayKnowFromEducation ?? this.peopleYouMayKnowFromEducation,
      receivedInvitationsCount:
          receivedInvitationsCount ?? this.receivedInvitationsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

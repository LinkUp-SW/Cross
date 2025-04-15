import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/features/my-network/model/invitations_screen_model.dart';

class GrowTabState {
  final List<GrowTabPeopleCardsModel>? fromCurrentPosition;
  final List<GrowTabPeopleCardsModel>? recentActivity;
  final List<GrowTabPeopleCardsModel>? followThesePeople;
  final List<GrowTabPeopleCardsModel>? topEmergingCreators;
  final List<GrowTabNewsletterCardsModel>? yourCommunityFollow;
  final List<GrowTabPeopleCardsModel>? becauseYouFollow;
  final List<GrowTabPeopleCardsModel>? moreSuggestions;
  final List<InvitationsCardModel>? receivedInvitations;
  final int? receivedInvitationsCount;
  final bool isLoading;
  final bool error;

  const GrowTabState({
    this.fromCurrentPosition,
    this.recentActivity,
    this.followThesePeople,
    this.topEmergingCreators,
    this.yourCommunityFollow,
    this.becauseYouFollow,
    this.moreSuggestions,
    this.receivedInvitations,
    this.receivedInvitationsCount,
    required this.isLoading,
    required this.error,
  });

  factory GrowTabState.initial() {
    return const GrowTabState(
      fromCurrentPosition: null,
      recentActivity: null,
      followThesePeople: null,
      topEmergingCreators: null,
      yourCommunityFollow: null,
      becauseYouFollow: null,
      moreSuggestions: null,
      receivedInvitations: null,
      receivedInvitationsCount: null,
      isLoading: true,
      error: false,
    );
  }

  GrowTabState copyWith({
    List<GrowTabPeopleCardsModel>? fromCurrentPosition,
    List<GrowTabPeopleCardsModel>? recentActivity,
    List<GrowTabPeopleCardsModel>? followThesePeople,
    List<GrowTabPeopleCardsModel>? topEmergingCreators,
    List<GrowTabNewsletterCardsModel>? yourCommunityFollow,
    List<GrowTabPeopleCardsModel>? becauseYouFollow,
    List<GrowTabPeopleCardsModel>? moreSuggestions,
    List<InvitationsCardModel>? receivedInvitations,
    int? receivedInvitationsCount,
    bool? isLoading,
    bool? error,
  }) {
    return GrowTabState(
      fromCurrentPosition: fromCurrentPosition ?? this.fromCurrentPosition,
      recentActivity: recentActivity ?? this.recentActivity,
      followThesePeople: followThesePeople ?? this.followThesePeople,
      topEmergingCreators: topEmergingCreators ?? this.topEmergingCreators,
      yourCommunityFollow: yourCommunityFollow ?? this.yourCommunityFollow,
      becauseYouFollow: becauseYouFollow ?? this.becauseYouFollow,
      moreSuggestions: moreSuggestions ?? this.moreSuggestions,
      receivedInvitations: receivedInvitations ?? this.receivedInvitations,
      receivedInvitationsCount:
          receivedInvitationsCount ?? this.receivedInvitationsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

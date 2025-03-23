import 'package:link_up/features/my-network/model/model.dart';

class GrowTabState {
  final List<GrowTabPeopleCardsModel>? fromCurrentPosition;
  final List<GrowTabPeopleCardsModel>? recentActivity;
  final List<GrowTabPeopleCardsModel>? followThesePeople;
  final List<GrowTabPeopleCardsModel>? topEmergingCreators;
  final List<GrowTabNewsletterCardsModel>? yourCommunityFollow;
  final List<GrowTabPeopleCardsModel>? becauseYouFollow;
  final List<GrowTabPeopleCardsModel>? moreSuggestions;
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
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class InvitationsScreenState {
  final List<InvitationsCardModel>? received;
  final List<InvitationsCardModel>? sent;
  final bool isLoading;
  final bool error;

  const InvitationsScreenState({
    this.received,
    this.sent,
    required this.isLoading,
    required this.error,
  });

  factory InvitationsScreenState.initial() {
    return const InvitationsScreenState(
      received: null,
      sent: null,
      isLoading: true,
      error: false,
    );
  }

  InvitationsScreenState copyWith({
    final List<InvitationsCardModel>? received,
    final List<InvitationsCardModel>? sent,
    bool? isLoading,
    bool? error,
  }) {
    return InvitationsScreenState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

import 'package:link_up/features/my-network/model/model.dart';

class GrowTabState {
  final List<GrowTabPeopleCardsModel>? fromUniversity;
  final List<GrowTabPeopleCardsModel>? recentActivity;
  final List<GrowTabPeopleCardsModel>? followThesePeople;
  final List<GrowTabPeopleCardsModel>? topEmergingCreators;
  final List<GrowTabNewsletterCardsModel>? yourCommunityFollow;
  final List<GrowTabPeopleCardsModel>? becauseYouFollow;
  final List<GrowTabPeopleCardsModel>? moreSuggestions;
  final bool isLoading;
  final bool error;

  const GrowTabState({
    required this.fromUniversity,
    required this.recentActivity,
    required this.followThesePeople,
    required this.topEmergingCreators,
    required this.yourCommunityFollow,
    required this.becauseYouFollow,
    required this.moreSuggestions,
    required this.isLoading,
    required this.error,
  });

  factory GrowTabState.initial() {
    return const GrowTabState(
      fromUniversity: [],
      recentActivity: [],
      followThesePeople: [],
      topEmergingCreators: [],
      yourCommunityFollow: [],
      becauseYouFollow: [],
      moreSuggestions: [],
      isLoading: true,
      error: false,
    );
  }

  GrowTabState copyWith({
    List<GrowTabPeopleCardsModel>? fromUniversity,
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
      fromUniversity: fromUniversity ?? this.fromUniversity,
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

class MyNetworkScreenState {
  final GrowTabState growTabState;

  const MyNetworkScreenState({
    required this.growTabState,
  });

  factory MyNetworkScreenState.initial() {
    return MyNetworkScreenState(growTabState: GrowTabState.initial());
  }

  MyNetworkScreenState copyWith({
    GrowTabState? growTabState,
  }) {
    return MyNetworkScreenState(
        growTabState: growTabState ?? this.growTabState);
  }
}

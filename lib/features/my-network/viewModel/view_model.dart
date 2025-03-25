import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/model.dart';
import 'package:link_up/features/my-network/services/service.dart';
import 'package:link_up/features/my-network/state/state.dart';

class GrowTabViewModel extends StateNotifier<GrowTabState> {
  final GrowTabServices _growTabServices;

  GrowTabViewModel(this._growTabServices) : super(GrowTabState.initial());

  // Initializer method - called when the screen is first loaded
  Future<void> fetchGrowTabData() async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: false,
      );

      // Load all data concurrently for better performance
      await Future.wait([
        _loadFromUniversity(),
        _loadRecentActivity(),
        _loadFollowThesePeople(),
        _loadTopEmergingCreators(),
        _loadYourCommunityFollow(),
        _loadBecauseYouFollow(),
        _loadMoreSuggestions(),
      ]);

      // Mark loading as complete
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        isLoading: false,
        error: true,
      );
    }
  }

  // Individual data loaders
  Future<void> _loadFromUniversity() async {
    try {
      final response = await _growTabServices.getFromCurrentPosition();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        fromCurrentPosition: data,
      );
    } catch (e) {
      // Handle errors for this specific section
      print('Error loading university connections: $e');
    }
  }

  Future<void> _loadRecentActivity() async {
    try {
      final response = await _growTabServices.getRecentActivity();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        recentActivity: data,
      );
    } catch (e) {
      print('Error loading recent activity: $e');
    }
  }

  Future<void> _loadFollowThesePeople() async {
    try {
      final response = await _growTabServices.getFollowThesePeople();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        followThesePeople: data,
      );
    } catch (e) {
      print('Error loading follow suggestions: $e');
    }
  }

  Future<void> _loadTopEmergingCreators() async {
    try {
      final response = await _growTabServices.getTopEmergingCreators();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        topEmergingCreators: data,
      );
    } catch (e) {
      print('Error loading emerging creators: $e');
    }
  }

  Future<void> _loadYourCommunityFollow() async {
    try {
      final response = await _growTabServices.getYourCommunityFollow();
      final data = (response['data'] as List)
          .map((item) => GrowTabNewsletterCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        yourCommunityFollow: data,
      );
    } catch (e) {
      print('Error loading community: $e');
    }
  }

  Future<void> _loadBecauseYouFollow() async {
    try {
      final response = await _growTabServices.getBecauseYouFollow();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        becauseYouFollow: data,
      );
    } catch (e) {
      print('Error loading because you follow: $e');
    }
  }

  Future<void> _loadMoreSuggestions() async {
    try {
      final response = await _growTabServices.getMoreSuggestions();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        moreSuggestions: data,
      );
    } catch (e) {
      print('Error loading more suggestions: $e');
    }
  }
}

// Provider for the view model
final myNetworkScreenViewModelProvider =
    StateNotifierProvider<GrowTabViewModel, GrowTabState>((ref) {
  return GrowTabViewModel(ref.read(growTabServicesProvider));
});

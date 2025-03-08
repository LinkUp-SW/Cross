import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/model.dart';
import 'package:link_up/features/my-network/services/service.dart';
import 'package:link_up/features/my-network/state/state.dart';

class MyNetworkScreenViewModel extends StateNotifier<MyNetworkScreenState> {
  final MyNetworkScreenServices _myNetworkScreenServices;

  MyNetworkScreenViewModel(this._myNetworkScreenServices)
      : super(MyNetworkScreenState.initial());

  // Initializer method - called when the screen is first loaded
  Future<void> initializeGrowTab() async {
    try {
      // Set loading state
      state = state.copyWith(
        growTabState:
            state.growTabState.copyWith(isLoading: true, error: false),
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
        growTabState: state.growTabState.copyWith(isLoading: false),
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        growTabState:
            state.growTabState.copyWith(isLoading: false, error: true),
      );
    }
  }

  // Individual data loaders
  Future<void> _loadFromUniversity() async {
    try {
      final response = await _myNetworkScreenServices.getFromUniversity();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(fromUniversity: data),
      );
    } catch (e) {
      // Handle errors for this specific section
      print('Error loading university connections: $e');
    }
  }

  Future<void> _loadRecentActivity() async {
    try {
      final response = await _myNetworkScreenServices.getRecentActivity();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(recentActivity: data),
      );
    } catch (e) {
      print('Error loading recent activity: $e');
    }
  }

  Future<void> _loadFollowThesePeople() async {
    try {
      final response = await _myNetworkScreenServices.getFollowThesePeople();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(followThesePeople: data),
      );
    } catch (e) {
      print('Error loading follow suggestions: $e');
    }
  }

  Future<void> _loadTopEmergingCreators() async {
    try {
      final response = await _myNetworkScreenServices.getTopEmergingCreators();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(topEmergingCreators: data),
      );
    } catch (e) {
      print('Error loading emerging creators: $e');
    }
  }

  Future<void> _loadYourCommunityFollow() async {
    try {
      final response = await _myNetworkScreenServices.getYourCommunityFollow();
      final data = (response['data'] as List)
          .map((item) => GrowTabNewsletterCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(yourCommunityFollow: data),
      );
    } catch (e) {
      print('Error loading community: $e');
    }
  }

  Future<void> _loadBecauseYouFollow() async {
    try {
      final response = await _myNetworkScreenServices.getBecauseYouFollow();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(becauseYouFollow: data),
      );
    } catch (e) {
      print('Error loading because you follow: $e');
    }
  }

  Future<void> _loadMoreSuggestions() async {
    try {
      final response = await _myNetworkScreenServices.getMoreSuggestions();
      final data = (response['data'] as List)
          .map((item) => GrowTabPeopleCardsModel.fromJson(item))
          .toList();

      state = state.copyWith(
        growTabState: state.growTabState.copyWith(moreSuggestions: data),
      );
    } catch (e) {
      print('Error loading more suggestions: $e');
    }
  }

  // Public methods for user interactions
  Future<void> refreshGrowTab() async {
    await initializeGrowTab();
  }
}

// Provider for the view model
final myNetworkScreenViewModelProvider =
    StateNotifierProvider<MyNetworkScreenViewModel, MyNetworkScreenState>(
        (ref) {
  final services = ref.watch(myNetworkScreenServicesProvider);
  return MyNetworkScreenViewModel(services);
});

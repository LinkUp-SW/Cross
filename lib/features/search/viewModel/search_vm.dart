import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel {
  TabController? tabController;
  SearchController searchController = SearchController();
  String searchText = '';
  SearchViewModel(
      {required this.tabController, required this.searchController});

  SearchViewModel.initial() : tabController = null;

  SearchViewModel copyWith({
    TabController? tabController,
    SearchController? searchController,
  }) {
    return SearchViewModel(
      tabController: tabController ?? this.tabController,
      searchController: searchController ?? this.searchController,
    );
  }

  setTabController(TabController tabController) {
    this.tabController = tabController;
  }

  setSearchController(SearchController searchController) {
    this.searchController = searchController;
  }
}

class SearchNotifier extends StateNotifier<SearchViewModel> {
  SearchNotifier() : super(SearchViewModel.initial());

  void setTabController(TabController tabController) {
    state.setTabController(tabController);
  }

  void setSearchController(SearchController searchController) {
    state.setSearchController(searchController);
  }

  void setSearchText(String text) {
    state.searchText = text;
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchViewModel>((ref) {
  return SearchNotifier();
});

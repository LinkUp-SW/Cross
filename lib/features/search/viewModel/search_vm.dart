

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel {
  TabController? tabController;
  SearchController searchController = SearchController();
  String searchText = '';
  SearchViewModel({required this.tabController, required this.searchController});

  SearchViewModel.initial()
      : tabController = null;

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
    state.tabController!.addListener(() {
      if (state.tabController!.indexIsChanging) {
        search();
      }
    });
  }

  void setSearchController(SearchController searchController) {
    state.setSearchController(searchController);
  }

  Future<void> search(){
    if (state.tabController == null || state.tabController!.index == 0) {
      return searchUsers();
    }
    else{
      return searchPosts();
    }
  }

  void setSearchText(String text) {
    state.searchText = text;
  }

  Future<void> searchUsers() async {
    //TODO: Implement your search user logic here
    log("Searching for users with text: ${state.searchText}");
    
  }

  Future<void> searchPosts() async {
    //TODO: Implement your search post logic here
    log("Searching for posts with text: ${state.searchText}");
  }
  
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchViewModel>((ref) {
  return SearchNotifier();
});
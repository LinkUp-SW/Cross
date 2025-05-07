import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'dart:developer';

class SearchPostState {
  bool isLoadingMore;
  int? cursor;
  List<PostModel> posts = [];

  SearchPostState({
    required this.isLoadingMore,
    required this.cursor,
  });

  SearchPostState.initial()
      : isLoadingMore = false,
        cursor = 0;
}

class PostTabVm extends StateNotifier<SearchPostState> {
  PostTabVm()
      : super(
          SearchPostState.initial(),
        );

  void clearPosts() {
    state.posts.clear();
    state.cursor = 0;
  }

  Future<void> loadsearchPosts(String searchQuery) async {
    final BaseService baseService = BaseService();
    state.isLoadingMore = true;
    await baseService.get('api/v2/post/search/posts', queryParameters: {
      'query': searchQuery,
      'cursor': state.cursor.toString(),
      'limit': '10',
    }).then((response) {
      log('Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<PostModel> fetchedPosts = (data['posts'] as List)
            .map((post) => PostModel.fromJson(post))
            .toList();
        state.posts.addAll(fetchedPosts);
        state.isLoadingMore = false;
        state.cursor = data['next_cursor'];
      } else {
        log('Error fetching posts: ${response.statusCode}');
      }
    }).catchError((error) {
      log('Error fetching posts: $error');
    });
  }
}

final searchPostProvider = StateNotifierProvider<PostTabVm, SearchPostState>(
  (ref) => PostTabVm(),
);

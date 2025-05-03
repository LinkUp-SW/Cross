import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';


class PostFeedState {
  bool showUndo = false;
  PostModel post;
  PostFeedState({this.showUndo = false, required this.post});


  
}


class PostsState {
  List<PostFeedState> posts;
  PostsState({required this.posts});
  int nextCursor = 0;
  bool isLoading = false;

  PostsState.initial()
      : posts = [],
        nextCursor = 0,
        isLoading = false;


}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier() : super(PostsState.initial());

  void addPosts(List<PostModel> posts) {
    state.posts.addAll(posts.map((e) => PostFeedState(post: e)).toList());
  }

  void clearPosts() {
    state.posts.clear();
  }

  void removePost(String id) {
    state.posts =
    state.posts.where((element) => element.post.id != id).toList();
  }

  void showUndo(String id) {
    state.posts = state.posts
        .map((e) => e.post.id == id
            ? PostFeedState(post: e.post, showUndo: !e.showUndo)
            : e)
        .toList();
  }

  void updatePost(PostModel post) {
    state.posts = state.posts
        .map((e) => e.post.id == post.id
            ? PostFeedState(post: post, showUndo: e.showUndo)
            : e)
        .toList();
  }

  void setPosts(List<PostModel> posts) {
    state.posts.clear();
    state.posts.addAll(posts.map((e) => PostFeedState(post: e)).toList());
  }

  Future<void> refreshPosts() {
    state.nextCursor = 0;
    state.posts.clear();
    return fetchPosts().then((value) {
      addPosts(value);
    });
  }

  Future<List<PostModel>> fetchPosts() async {
    state.isLoading = true;
    final BaseService service = BaseService();
    try {
      final response =
          await service.get('api/v2/post/posts/feed', queryParameters: {
        'limit': '20',
        'cursor': state.nextCursor.toString(),
      });
      state.isLoading = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Fetched posts: $data');
        final List<PostModel> posts =
            (data['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
        state.nextCursor = data['next_cursor'] ?? -1;
        return posts;
      } else {
        log('Failed to fetch posts: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      log('Error fetching posts: $error');
      state.isLoading = false;
      return [];
    }
  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});

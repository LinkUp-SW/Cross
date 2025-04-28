import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostState{
  bool showUndo = false;
  PostModel post;
  PostState({this.showUndo = false,required this.post});
  static var nextCursor = 0;
}

class PostsNotifier extends StateNotifier<List<PostState>> {
  PostsNotifier() : super([]);

  void addPosts(List<PostModel> posts) {
    
    state = [...state, ...posts.map((e) => PostState(post: e))];
  }

  void removePost(String id) {
    state = state.where((element) => element.post.id != id).toList();
  }

  void showUndo(String id) {
    state = state.map((e) => e.post.id == id ? PostState(post: e.post, showUndo: !e.showUndo) : e).toList();
  }

  void updatePost(PostModel post) {
    state = state.map((e) => e.post.id == post.id ? PostState(post: post,showUndo: e.showUndo) : e).toList();
  }

  void setPosts(List<PostModel> posts) {
    state = posts.map((e) => PostState(post: e)).toList();
  }

  Future<void> refreshPosts() {
    return fetchPosts().then((value) {
      state = value.map((e) => PostState(post: e)).toList();
    });
  }

  Future<List<PostModel>> fetchPosts() async {
    //TODO: Implement fetchPosts form backend
    // Take note that the repost with thoughts could cause problems so check should be done
    final BaseService service = BaseService();
    log('Fetching posts with cursor: ${PostState.nextCursor}');
    final response = await service.get('api/v1/post/posts/feed',queryParameters: {
      'limit': '20',
      'cursor': PostState.nextCursor.toString(),
    });
    if(response.statusCode == 200) {
      final data =jsonDecode(response.body);
      log('Fetched posts: $data');
      final List<PostModel> posts = (data['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
      PostState.nextCursor = data['nextCursor'] ?? -1;
      return posts;
    } else {
      log('Failed to fetch posts: ${response.statusCode}');
      throw Exception('Failed to load posts');  
    }

  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, List<PostState>>((ref) {
  return PostsNotifier();
});

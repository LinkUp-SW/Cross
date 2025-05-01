import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostState {
  PostModel post;
  bool isLoading;
  PostState({required this.post, required this.isLoading});
  PostState.initial()
      : post = PostModel.initial(),
        isLoading = false;
} 

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(PostState.initial());

  void setPost(PostModel post) {
    state.post = post;
  }

  void setPostId(String postId) {
    state.post.id = postId;
  }

  String getPostId() {
    return state.post.id;
  }

  Future<Map<String,dynamic>> getPost(String id) async {
    log('getPost called with id: $id');
    state.isLoading = true;
    final BaseService service = BaseService();
    return await service.get('api/v2/post/posts/:postId',
        queryParameters: {
          'limit': '10',
          'cursor': '0',
          'replyLimit': '1',
        },
        routeParameters: {"postId": id}).then((value) {
      log(value.body);
      final data = jsonDecode(value.body);
      state.post = PostModel.fromJson(data['post']);
      state.isLoading = false;
      return data['comments'];
    }).catchError((error) {
      log('$error');
      throw Exception(error);
    });
  }
}

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier();
});

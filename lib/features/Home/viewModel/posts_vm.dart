

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super([]);

  void addPost(PostModel post) {
    state = [...state, post];
  }

  void removePost(PostModel post) {
    state = state.where((element) => element.id != post.id).toList();
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, List<PostModel>>((ref) {
  return PostsNotifier();
});
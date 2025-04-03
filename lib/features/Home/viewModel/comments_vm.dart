

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';

class CommentsProvider extends StateNotifier<List<CommentModel>> {
  CommentsProvider() : super([]);

  void addComments(List<CommentModel> comments) {
    state = [...state, ...comments];
  }

  void removeComment(CommentModel comment) {
    state = state.where((element) => element.id != comment.id).toList();
  }

  void updateComment(CommentModel comment) {
    state = state.map((e) => e.id == comment.id ? comment : e).toList();
  }

  void setComments(List<CommentModel> comments) {
    state = comments;
  }

  void clearComments() {
    state = [];
  }


  Future<List<CommentModel>> fetchComments(String postId) {
      //TODO: Implement fetching comments from the server
      log(postId);
      return Future.delayed(const Duration(seconds: 5), () {
        return List.generate(
          5,
          (index) => CommentModel(
            id: index.toString(),
            header: HeaderModel(
              userId: index.toString(),
              profileImage:
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
              name: 'John Doe',
              connectionDegree: 'johndoe',
              about: 'About John Doe',
              timeAgo: DateTime.now(),
              visibilityPost: Visibilities.anyone,
              visibilityComments: Visibilities.anyone,
            ),
            text: 'This is a comment',
            likes: 10,
            replies: 5,
            media: Media(
              type: index % 3 == 2
                      ? MediaType.image
                      : MediaType.none,
              urls: [
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
              ],
            ),
          ),
        );
      });
  }

}

final commentsProvider = StateNotifierProvider<CommentsProvider, List<CommentModel>>((ref) {
  return CommentsProvider();
});
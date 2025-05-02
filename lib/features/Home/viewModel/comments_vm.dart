import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/comment_model.dart';

class CommentsProvider extends StateNotifier<Map<String, dynamic>> {
  CommentsProvider() : super({'comments': [], 'cursor': 0});

  void addComments(List<CommentModel> comments) {
    state['comments'].addAll(comments);
  }

  void removeComment(CommentModel comment) {
    state =
        state['comments'].where((element) => element.id != comment.id).toList();
  }

  void updateComment(CommentModel comment) {
    state =
        state['comments'].map((e) => e.id == comment.id ? comment : e).toList();
  }

  void setComments(List<CommentModel> comments) {
    state['comments'].clear();
    state['comments'].addAll(comments);
  }

  void setCommentsFromPost(Map<String, dynamic> comments) {
    state['comments'].clear();
    state['comments'].addAll(
        comments['comments'].map((e) => CommentModel.fromJson(e)).toList());
    state['cursor'] = comments['next_cursor'];
  }

  void clearComments() {
    state['comments'].clear();
  }

  Future<List<CommentModel>> fetchComments(String postId, {int? cursor}) {
    final BaseService service = BaseService();
    log('Fetching comments for postId: $postId');
    return service.get(
      'api/v2/post/comment/:postId',
      queryParameters: {
        'limit': '10',
        'cursor': (cursor ?? state['cursor']).toString(),
        'replyLimit': '1',
      },
      routeParameters: {
        'postId': postId,
      },
    ).then((value) {
      final data = jsonDecode(value.body);
      log('Fetched comments: $data');
      state['cursor'] = data['next_cursor'];
      return (data['comments'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();
    }).catchError((error) {
      log('$error');
      return <CommentModel>[];
    });
  }
}

final commentsProvider =
    StateNotifierProvider<CommentsProvider, Map<String, dynamic>>((ref) {
  return CommentsProvider();
});

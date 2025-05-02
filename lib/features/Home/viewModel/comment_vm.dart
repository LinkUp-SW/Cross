import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/comment_model.dart';

class CommentState {
  CommentModel comment;
  int? cursor = 0;
  CommentState({required this.comment});
  CommentState.initial() : comment = CommentModel.initial();
}

class CommentProvider extends StateNotifier<CommentState> {
  CommentProvider() : super(CommentState.initial());

  void setComment(CommentModel comment) {
    state.comment = comment;
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final BaseService service = BaseService();
    return await service.delete('api/v2/post/comment/:postId/:commentId',
        {"postId": postId, "commentId": commentId}).then((value) {
      state.comment = CommentModel.initial();
    }).catchError((error) {
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      throw Exception('Request timed out');
    });
  }

  void setCommentReplies(List<CommentModel> replies) {
    state.comment.repliesList.clear();
    state.comment.repliesList.addAll(replies);
  }

  void addCommentReplies(List<CommentModel> replies) {
    state.comment.repliesList.addAll(replies);
  }

  Future<List<CommentModel>> fetchCommentReplies(String postId,
      {int? cursor}) async {
    final BaseService service = BaseService();
    final response = await service.get(
      'api/v2/post/comment/:postId/:commentId',
      queryParameters: {
        'replyLimit': '10',
        'cursor': (cursor ?? state.cursor).toString(),
      },
      routeParameters: {
        'postId': postId,
        'commentId': state.comment.id,
      },
    );
    if (response.statusCode != 200) {
      log('Failed to load comments: ${response.statusCode}');
      throw Exception('Failed to load comments');
    }
    final data = jsonDecode(response.body);
    log('Comments: $data');
    state.cursor = data['next_cursor'];
    return (data['replies'] as List)
        .map((e) => CommentModel.fromJson(e))
        .toList();
  }
}

final commentProvider =
    StateNotifierProvider<CommentProvider, CommentState>((ref) {
  return CommentProvider();
});

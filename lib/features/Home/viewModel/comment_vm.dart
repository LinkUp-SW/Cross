

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/model/comment_model.dart';

class CommentProvider extends StateNotifier<CommentModel> {
  CommentProvider() : super(CommentModel.initial());

  void setComment(CommentModel comment) {
    state = comment;
  }

  Future<void> deleteComment(String postId,String commentId) async {
    final BaseService service = BaseService();
    return await service.delete('api/v1/post/comment/:postId/:commentId', {"postId": postId,"commentId": commentId}).then((value) {
      state = CommentModel.initial();
    }).catchError((error) {
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      throw Exception('Request timed out');
    });
  }


}

final commentProvider = StateNotifierProvider<CommentProvider, CommentModel>((ref) {
  return CommentProvider();
});
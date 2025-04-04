

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/model/comment_model.dart';

class CommentProvider extends StateNotifier<CommentModel> {
  CommentProvider() : super(CommentModel.initial());

  void setComment(CommentModel comment) {
    state = comment;
  }


}

final commentProvider = StateNotifierProvider<CommentProvider, CommentModel>((ref) {
  return CommentProvider();
});
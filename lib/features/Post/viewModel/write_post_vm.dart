import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class WritePostVm {
  Visibilities visbilityPost;
  Visibilities visibilityComment;
  //bool brandPartnerships = false;
  TextEditingController controller;
  Media media;

  WritePostVm(
      {required this.visbilityPost,
      required this.visibilityComment,
      required this.media,
      required this.controller});
  WritePostVm.initial()
      : visbilityPost = Visibilities.anyone,
        visibilityComment = Visibilities.anyone,
        controller = TextEditingController(),
        media = Media.initial();

  WritePostVm copyWith({
    Visibilities? visbilityPost,
    Visibilities? visibilityComment,
    Media? media,
    TextEditingController? controller,
  }) {
    return WritePostVm(
        visbilityPost: visbilityPost ?? this.visbilityPost,
        visibilityComment: visibilityComment ?? this.visibilityComment,
        media: media ?? this.media,
        controller: controller ?? this.controller);
  }
}

class WritePostProvider extends StateNotifier<WritePostVm> {
  WritePostProvider() : super(WritePostVm.initial());

  void setVisibilityPost(Visibilities visibility) {
    state = state.copyWith(visbilityPost: visibility);
  }

  void setVisibilityComment(Visibilities visibility) {
    state = state.copyWith(visibilityComment: visibility);
  }

  void setMedia(Media media) {
    state = state.copyWith(media: media);
  }

  void clearWritePost() {
    state = WritePostVm.initial();
  }
  

  Future<String> createPost() async {
    //TODO: send tempPost to backend
    PostModel tempPost = PostModel(
        id: 'noId',
        header: HeaderModel.initial(),
        text: state.controller.text,
        media: state.media,
        reactions: 0,
        comments: 0,
        reposts: 0,
        reaction: Reaction.none);
    return await Future.delayed(const Duration(milliseconds: 2000), () {
      log(jsonEncode(tempPost.toJson()));
      return true;
    }).then((value) => tempPost.id);
  }
}

final writePostProvider =
    StateNotifierProvider<WritePostProvider, WritePostVm>((ref) {
  return WritePostProvider();
});

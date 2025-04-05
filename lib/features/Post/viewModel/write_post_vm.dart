import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';

class WritePostVm {
  Visibilities visbilityPost;
  Visibilities visibilityComment;
  //bool brandPartnerships = false;
  TextEditingController controller;
  Media media;
  bool isEdited = false;

  WritePostVm({
    required this.visbilityPost,
    required this.visibilityComment,
    required this.media,
    required this.controller,
    this.isEdited = false,
  });
  WritePostVm.initial()
      : visbilityPost = Visibilities.anyone,
        visibilityComment = Visibilities.anyone,
        controller = TextEditingController(),
        isEdited = false,
        media = Media.initial();

  WritePostVm copyWith({
    Visibilities? visbilityPost,
    Visibilities? visibilityComment,
    Media? media,
    bool? isEdited,
    TextEditingController? controller,
  }) {
    return WritePostVm(
        visbilityPost: visbilityPost ?? this.visbilityPost,
        visibilityComment: visibilityComment ?? this.visibilityComment,
        media: media ?? this.media,
        isEdited: isEdited ?? this.isEdited,
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

  void setPost(PostModel post, bool isEdited) {
    state = WritePostVm(
      isEdited: isEdited,
      visbilityPost: post.header.visibilityPost,
      visibilityComment: post.header.visibilityComments,
      media: post.media,
      controller: TextEditingController(text: post.text),
    );
  }

  Future<String> createPost() async {
    //TODO: send tempPost to backend
    final BaseService service = BaseService();
    final mediaContent = [
      if (state.media.type == MediaType.link)
        ...state.media.urls
      else if (state.media.type == MediaType.post)
        state.media.post!.id
      else if (state.media.type == MediaType.pdf)
        base64Encode(await File(state.media.file[0]).readAsBytes())
      else
        for (int i = 0; i < state.media.file.length; i++)
          {
            base64Encode(await File(state.media.file[i]!.path).readAsBytes()),
          }
    ];
    //log(mediaContent.toString());
    final response = await service.post('api/v1/post/create-post', body: {
      "content": state.controller.text,
      "mediaType": state.media.type.name,
      "media": mediaContent,
      "commentsDisabled":
          Visibilities.getVisibilityString(state.visibilityComment),
      "publicPost": state.visbilityPost == Visibilities.anyone ? true : false,
      "taggedUsers": []
    });
    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post created successfully: ${response.body}');
      return 'created';
      //return jsonDecode(response.body)['postId'];
    } else {
      log('Failed to create post');
      return 'error';
    }
  }
}

final writePostProvider =
    StateNotifierProvider<WritePostProvider, WritePostVm>((ref) {
  return WritePostProvider();
});

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Post/widgets/formatted_input.dart';
import 'package:link_up/features/Post/widgets/formatting_styles.dart';

final context = navigatorKey.currentContext!;

class WriteCommentVm {
  TextEditingController controller;
  Media media;
  bool isEdited = false;
  bool isReply = false;
  String commentId = 'noId';
  List<dynamic> taggedUsers = [];

  WriteCommentVm({
    required this.media,
    required this.controller,
    this.isEdited = false,
    this.isReply = false,
  });

  WriteCommentVm.initial()
      : isEdited = false,
        media = Media.initial(),
        controller = TextEditingController(); // Use basic controller initially

  // Initialize styleable controller after construction
  void initController(
      BuildContext context, Function updateTags) {
    controller = StyleableTextFieldController(
      styles: TextPartStyleDefinitions(
        definitionList: [
          FormattingTextStyles.mentionStyle(
            context,
            onDetected: (mention) {
              final RegExp regex = RegExp(r'@([^@^:]+):([^@^]+)\^');
              final RegExpMatch? regMatch = regex.firstMatch(mention);
              if (regMatch != null) {
                final String username = regMatch.group(1) ?? '';
                final String userId = regMatch.group(2) ?? '';
                log('User detected: $username with ID: $userId');
                taggedUsers.add({
                  'username': username,
                  'userId': userId,
                });
                log(taggedUsers.toString());
              }
            },
            onDelete: (mention) {
              final RegExp regex = RegExp(r'@([^@^:]+):([^@^]+)\^');
              final RegExpMatch? regMatch = regex.firstMatch(mention);
              if (regMatch != null) {
                final String username = regMatch.group(1) ?? '';
                final String userId = regMatch.group(2) ?? '';
                log('User deleted: $username with ID: $userId');
                taggedUsers
                    .removeWhere((element) => element['userId'] == userId);
                log(taggedUsers.toString());
              }
            },
          ),
          TextPartStyleDefinition(
            pattern: r'@[\w ^:]*$',
            style: TextStyle(),
            onDetected: (p0) async{
              if (p0.length > 1) {
                final query = p0.substring(1);
                final BaseService baseService = BaseService();
                await baseService.get(
                  'api/v1/search/users?query=$query&limit=25&page=1').then((value) {
                  if (value.statusCode == 200) {
                    final body = jsonDecode(value.body);
                    updateTags(false,[]);
                    final List<dynamic> users = body['people'];
                    users.removeWhere((user) {
                      return taggedUsers.any((taggedUser) =>
                          taggedUser['user_id'] == user['user_id']);
                    });
                    log('Fetched users: $users');
                    updateTags(true, users);
                  } else {
                    log('Failed to fetch users');
                  }
                }).catchError((error) {
                  log('Error fetching users: $error');
                });
              }
            },
            preventPartialDeletion: true,
            onDelete: (p0) {
              log('Mention deleted: $p0');
              updateTags(false,[]);
            },
          ),
          FormattingTextStyles.boldStyle,
          FormattingTextStyles.italicStyle,
          FormattingTextStyles.underlineStyle,
        ],
      ),
    );
  }

  WriteCommentVm copyWith({
    Visibilities? visbilityPost,
    Visibilities? visibilityComment,
    Media? media,
    bool? isEdited,
    TextEditingController? controller,
  }) {
    return WriteCommentVm(
        media: media ?? this.media,
        isEdited: isEdited ?? this.isEdited,
        controller: controller ?? this.controller);
  }
}

class WriteCommentProvider extends StateNotifier<WriteCommentVm> {
  WriteCommentProvider() : super(WriteCommentVm.initial()) {
    state.initController(context, () {});
  }

  void setController(Function updateTags) {
    state.initController(context, updateTags);
  }

  void setVisibilityPost(Visibilities visibility) {
    state = state.copyWith(visbilityPost: visibility);
  }

  void setVisibilityComment(Visibilities visibility) {
    state = state.copyWith(visibilityComment: visibility);
  }

  void setMedia(Media media) {
    state = state.copyWith(media: media);
  }

  void tagUser(Map<String, dynamic> user) {
    state.taggedUsers.add(user);
  }

  void clearWritePost() {
    state = WriteCommentVm.initial();
    state.initController(context, () {});
  }

  void setComment(CommentModel comment, bool isEdited) {
    state.controller.text = comment.text;
    state.isEdited = isEdited;
    state.media = comment.media;
    state.commentId = comment.id;
  }

  Future<String> comment(String postId,String? commentId) async{
    if(state.isEdited) {
      return await editComment(postId,state.commentId);
    } else {
      return await createComment(postId,commentId);
    }
  }
  
  Future<String> editComment(String postId,String? commentId) async {
    final BaseService service = BaseService();
    log('Editing comment with postId: $postId, commentId: $commentId');

    final mediaContent = await state.media.setToUpload();
    final response = await service.patch('api/v2/post/comment/:postId/:commentId'
    , routeParameters: {
        "postId": postId,
        "commentId": commentId,
      }
    , body: {
      "content": state.controller.text,
      "media": mediaContent,
      "tagged_users": state.taggedUsers.map((user) {return user['user_id'];}).toList(),
    }).catchError((error) {
      log('Error editing comment: $error');
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      log('Request timed out');
      throw Exception('Request timed out');
    });
    log('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      log('Comment edited successfully: ${response.body}');
      return 'edited';
    } else {
      log('Failed to edit comment');
      return 'error';
    }
  }

  Future<String> createComment(String postId,String? commentId) async {
    final BaseService service = BaseService();
    log('Creating comment with postId: $postId, commentId: $commentId');

    final mediaContent = await state.media.setToUpload();
    final response = await service.post('api/v2/post/comment/:postId'
    , routeParameters: {
        "postId": postId,
      }
    , body: {
      "parent_id": commentId,
      "content": state.controller.text,
      "media": mediaContent,
      "tagged_users": state.taggedUsers.map((user) {return user['user_id'];}).toList(),
    }).catchError((error) {
      log('Error creating comment: $error');
      throw Exception(error);
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      log('Request timed out');
      throw Exception('Request timed out');
    });
    log('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      log('Comment created successfully: ${response.body}');
      return 'created';
      //return jsonDecode(response.body)['postId'];
    } else {
      log('Failed to create post');
      return 'error';
    }
  }
}

final writeCommentProvider =
    StateNotifierProvider<WriteCommentProvider, WriteCommentVm>((ref) {
  return WriteCommentProvider();
});

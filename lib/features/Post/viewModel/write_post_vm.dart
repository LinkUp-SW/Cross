import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Post/widgets/formatted_input.dart';
import 'package:link_up/features/Post/widgets/formatting_styles.dart';
import 'package:url_launcher/url_launcher.dart';

final context = navigatorKey.currentContext!;

class WritePostVm {
  Visibilities visbilityPost;
  Visibilities visibilityComment;
  //bool brandPartnerships = false;
  TextEditingController controller;
  Media media;
  List<dynamic> taggedUsers = [];
  String postId = 'noId';

  WritePostVm({
    required this.visbilityPost,
    required this.visibilityComment,
    required this.media,
    required this.controller,
    this.postId = 'noId',
    this.taggedUsers = const [],
  });

  WritePostVm.initial()
      : visbilityPost = Visibilities.anyone,
        visibilityComment = Visibilities.anyone,
        media = Media.initial(),
        controller = TextEditingController(); // Use basic controller initially

  // Initialize styleable controller after construction
  void initController(
      BuildContext context, Function updateTags, Function setMedia) {
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
          FormattingTextStyles.urlStyle(
            context,
            onTap: (url) async {
              url = url.trim();
              final isAccessible = await isAccessibleUrl(url);
              if (isAccessible) {
                launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
              } else {
                log('URL is not accessible: $url');
                // Show feedback in your app
              }
            },
            onDetected: (url) async {
              url = url.trim();
              final isAccessible = await isAccessibleUrl(url);
              if (isAccessible) {
                if (media.type == MediaType.none) {
                  setMedia(Media(
                    type: MediaType.link,
                    urls: [url],
                  ));
                }
              } else {
                log('URL is not accessible: $url');
                // Show feedback in your app
              }
            },
          ),
          TextPartStyleDefinition(
            pattern: r'@[\w ^:]*$',
            style: TextStyle(),
            onDetected: (p0) async {
              if (p0.length > 1) {
                final query = p0.substring(1);
                final BaseService baseService = BaseService();
                await baseService
                    .get('api/v1/search/users?query=$query&limit=25&page=1')
                    .then((value) {
                  if (value.statusCode == 200) {
                    final body = jsonDecode(value.body);
                    updateTags(false, []);
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
              updateTags(false, []);
            },
          ),
          FormattingTextStyles.boldStyle,
          FormattingTextStyles.italicStyle,
          FormattingTextStyles.underlineStyle,
        ],
      ),
    );
  }

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
        controller: controller ?? this.controller);
  }
}

class WritePostProvider extends StateNotifier<WritePostVm> {
  WritePostProvider() : super(WritePostVm.initial()) {
    state.initController(context, () {}, () {});
  }

  void setController(Function updateTags, Function setMedia, {String? text}) {
    state.initController(context, updateTags, setMedia);
    state.controller.text = text ?? '';
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
    state = WritePostVm.initial();
    state.initController(context, () {}, () {});
  }

  void setPost(PostModel post, bool isEdited) {
    state.controller.text = post.text;
    state = WritePostVm(
      taggedUsers: post.taggedUsers,
      postId: post.id,
      visbilityPost: post.header.visibilityPost,
      visibilityComment: post.header.visibilityComments,
      media: post.media,
      controller: state.controller,
    );
  }

  Future<String> post() async {
    if (state.postId != 'noId') {
      return await editPost();
    } else {
      return await createPost();
    }
  }

  Future<String> editPost() async {
    final BaseService service = BaseService();

    final mediaContent = await state.media.setToUpload();

    final response =
        await service.patch('api/v2/post/posts/:postId', routeParameters: {
      "postId": state.postId
    }, body: {
      "content": state.controller.text,
      "mediaType": state.media.type.name,
      "media": mediaContent,
      "commentsDisabled":
          Visibilities.getVisibilityString(state.visibilityComment),
      "publicPost": state.visbilityPost == Visibilities.anyone ? true : false,
      "taggedUsers": state.taggedUsers.map((user) {
        return user['user_id'];
      }).toList(),
    });

    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post edited successfully: ${response.body}');
      return state.postId;
    } else {
      log('Failed to edit post');
      return 'error';
    }
  }

  Future<String> createPost() async {
    final BaseService service = BaseService();

    final mediaContent = await state.media.setToUpload();

    log('${state.taggedUsers.map((user) {
      return user['user_id'];
    }).toList()}');
    final response = await service.post('api/v2/post/posts', body: {
      "content": state.controller.text,
      "mediaType": state.media.type.name,
      "media": mediaContent,
      "commentsDisabled":
          Visibilities.getVisibilityString(state.visibilityComment),
      "publicPost": state.visbilityPost == Visibilities.anyone ? true : false,
      "taggedUsers": state.taggedUsers.map((user) {
        return user['user_id'];
      }).toList(),
    });

    // Rest of the function remains the same
    log('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      log('Post created successfully: ${response.body}');
      final body = jsonDecode(response.body);
      return body['postId'];
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

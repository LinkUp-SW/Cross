import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Post/widgets/formatted_input.dart';
import 'package:link_up/features/Post/widgets/formatting_styles.dart';

final context = navigatorKey.currentContext!;

class WriteCommentVm {
  TextEditingController controller;
  Media media;
  bool isEdited = false;
  List<dynamic> taggedUsers = [];

  WriteCommentVm({
    required this.media,
    required this.controller,
    this.isEdited = false,
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
            pattern: r'@[\w ]*',
            style: TextStyle(),
            onDetected: (p0) {
              log('Mention detected: $p0');
              if (p0.length > 1) {
                updateTags(true);
              }
            },
            preventPartialDeletion: true,
            onDelete: (p0) {
              log('Mention deleted: $p0');
              updateTags(false);
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

  void clearWritePost() {
    state = WriteCommentVm.initial();
    state.initController(context, () {});
  }

  void setComment(PostModel post, bool isEdited) {
    state = WriteCommentVm(
      isEdited: isEdited,
      media: post.media,
      controller: TextEditingController(text: post.text),
    );
  }

  Future<String> createComment() async {
    final BaseService service = BaseService();

    final mediaContent = <dynamic>[];

    if (state.media.type == MediaType.image) {
      // For images or other files
      if (state.media.file[0] != null) {
        final path = state.media.file[0]!.path;
        final bytes = await File(path).readAsBytes();

        // Determine MIME type from file extension
        String mimeType = '';
        if (path.toLowerCase().endsWith('.jpg') ||
            path.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else if (path.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (path.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        }

        final uriData = UriData.fromBytes(bytes, mimeType: mimeType);
        mediaContent.add(uriData.toString());
      }
    }

    final response = await service.post('api/v1/post/create-post', body: {
      "content": state.controller.text,
      "mediaType": state.media.type.name,
      "media": mediaContent,
      "taggedUsers": []
    });

    // Rest of the function remains the same
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

final writeCommentProvider =
    StateNotifierProvider<WriteCommentProvider, WriteCommentVm>((ref) {
  return WriteCommentProvider();
});

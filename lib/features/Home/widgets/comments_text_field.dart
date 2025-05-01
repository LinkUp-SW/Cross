import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/viewModel/comments_vm.dart';
import 'package:link_up/features/Home/viewModel/write_comment_vm.dart';
import 'package:link_up/features/Post/widgets/formatted_input.dart';
import 'package:link_up/shared/themes/colors.dart';

class CommentsTextField extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final String buttonName;
  final bool showSuggestions;
  final String postId;
  final Function refresh;
  final String? commentId;
  const CommentsTextField(
      {super.key,
      required this.postId,
      required this.refresh,
      required this.focusNode,
      required this.buttonName,
      this.commentId,
      this.showSuggestions = true});

  @override
  ConsumerState<CommentsTextField> createState() => _CommentsTextFieldState();
}

class _CommentsTextFieldState extends ConsumerState<CommentsTextField> {
  bool _showTags = false;
  bool _sending = false;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(writeCommentProvider.notifier).setController(
        (showTags, data) {
          if (_showTags != showTags) {
            setState(() {
              _showTags = showTags;
              users.clear();
              users.addAll(data);
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.showSuggestions ? 120.h : 70.h;
    final writeComment = ref.watch(writeCommentProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: const BorderDirectional(
            top: BorderSide(color: AppColors.lightGrey, width: 0)),
      ),
      height: widget.focusNode.hasFocus
          ? _showTags
              ? height + 245.h
              : height + 45.h
          : _showTags
              ? height + 210.h
              : height,
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {});
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_showTags) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          height: 200.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage: NetworkImage(
                                      users[index]['profile_photo']),
                                ),
                                title: Text(users[index]['name'],
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                subtitle: Text(users[index]['headline'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppColors.grey,
                                        )),
                                onTap: () {
                                  writeComment.controller.text =
                                      writeComment.controller.text.replaceRange(
                                    writeComment.controller.text
                                        .lastIndexOf('@'),
                                    writeComment.controller.text.length,
                                    "@${users[index]['name']}:${users[index]['user_id']}^ ",
                                  );
                                  setState(() {
                                    _showTags = false;
                                  });
                                },
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.lightGrey,
                              height: 0,
                            ),
                          ),
                        ),
                        const Divider(
                          color: AppColors.lightGrey,
                          height: 0,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                      if (widget.showSuggestions)
                        SizedBox(
                          height: 50.h,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  SizedBox(width: 5.w),
                              itemBuilder: (context, index) {
                                //TODO: Suggestions
                                return Chip(label: Text("label $index"));
                              }),
                        ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        spacing: 10.w,
                        children: [
                          Flexible(
                            flex: 1,
                            child: CircleAvatar(
                              radius: 20.r,
                              backgroundImage:
                                  NetworkImage(InternalEndPoints.profileUrl),
                            ),
                          ),
                          Flexible(
                            flex: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.r),
                                      child: FormattedInput(
                                        controller: writeComment.controller,
                                        focusNode: widget.focusNode,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    if (writeComment.media.type !=
                                        MediaType.none)
                                      Padding(
                                        padding: EdgeInsets.all(
                                          10.r,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              child: SizedBox(
                                                  height: 120.h,
                                                  child: writeComment.media
                                                      .getMedia()),
                                            ),
                                            IconButton(
                                                style: IconButton.styleFrom(
                                                  backgroundColor: AppColors
                                                      .fineLinesGrey
                                                      .withValues(alpha: 0.7),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    ref
                                                        .read(
                                                            writeCommentProvider
                                                                .notifier)
                                                        .setMedia(
                                                          Media.initial(),
                                                        );
                                                  });
                                                },
                                                icon: const Icon(Icons.close)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!widget.focusNode.hasFocus)
                            Flexible(
                              flex:
                                  writeComment.controller.text.isEmpty ? 0 : 1,
                              child: writeComment.controller.text.isEmpty
                                  ? SizedBox()
                                  : IconButton.filled(
                                      onPressed: writeComment
                                                  .controller.text.isEmpty &&
                                              writeComment.media.type ==
                                                  MediaType.none
                                          ? null
                                          : () async {
                                              setState(() {
                                                _sending = true;
                                              });
                                              await ref
                                                  .read(writeCommentProvider
                                                      .notifier)
                                                  .comment(widget.postId,
                                                      widget.commentId);
                                              widget.focusNode.unfocus();
                                              ref
                                                  .read(writeCommentProvider
                                                      .notifier)
                                                  .clearWriteComment();
                                              setState(() {
                                                _sending = false;
                                                ref
                                                    .read(commentsProvider
                                                        .notifier)
                                                    .fetchComments(
                                                        widget.postId)
                                                    .then((value) {
                                                  ref
                                                      .read(commentsProvider
                                                          .notifier)
                                                      .addComments(value);
                                                });
                                              });
                                              widget.refresh();
                                            },
                                      icon: _sending
                                          ? CircularProgressIndicator()
                                          : Icon(
                                              Icons.arrow_upward,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                            ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                            )
                        ],
                      ),
                      if (widget.focusNode.hasFocus)
                        SizedBox(
                          height: 40.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if(writeComment.media.type == MediaType.none)
                                  GestureDetector(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final image = await picker.pickImage(
                                            source: ImageSource.gallery);
                                        setState(() {
                                          if (image != null) {
                                            ref
                                                .read(writeCommentProvider
                                                    .notifier)
                                                .setMedia(
                                                  Media(
                                                      isLocal: true,
                                                      urls: [],
                                                      type: MediaType.image,
                                                      files: [image]),
                                                );
                                          } else {
                                            throw Exception(
                                                'Could not add image');
                                          }
                                        });
                                      },
                                      child: const Icon(Icons.image)),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showTags = !_showTags;
                                          if (_showTags) {
                                            writeComment.controller.text +=
                                                '@ ';
                                          } else {
                                            writeComment.controller.text =
                                                writeComment.controller.text
                                                    .replaceRange(
                                              writeComment.controller.text
                                                  .lastIndexOf('@'),
                                              writeComment
                                                  .controller.text.length,
                                              "",
                                            );
                                          }
                                        });
                                      },
                                      child: const Icon(Icons.alternate_email))
                                ],
                              ),
                              Wrap(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        disabledForegroundColor: AppColors.grey,
                                        foregroundColor: AppColors.red),
                                    onPressed:
                                        writeComment.controller.text.isEmpty &&
                                                writeComment.media.type ==
                                                    MediaType.none
                                            ? null
                                            : () {
                                                ref
                                                    .read(writeCommentProvider
                                                        .notifier)
                                                    .clearWriteComment();
                                                    setState(() {});
                                              },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      disabledForegroundColor: AppColors.grey,
                                    ),
                                    onPressed: writeComment
                                                .controller.text.isEmpty &&
                                            writeComment.media.type ==
                                                MediaType.none
                                        ? null
                                        : () async {
                                            setState(() {
                                              _sending = true;
                                            });
                                            await ref
                                                .read(writeCommentProvider
                                                    .notifier)
                                                .comment(widget.postId,
                                                    widget.commentId);
                                            widget.focusNode.unfocus();
                                            ref
                                                .read(writeCommentProvider
                                                    .notifier)
                                                .clearWriteComment();
                                            setState(() {
                                              _sending = false;
                                              ref
                                                  .read(
                                                      commentsProvider.notifier)
                                                  .fetchComments(widget.postId)
                                                  .then((value) {
                                                ref
                                                    .read(commentsProvider
                                                        .notifier)
                                                    .addComments(value);
                                              });
                                            });
                                            widget.refresh();
                                            setState(() {});
                                          },
                                    child: _sending
                                        ? CircularProgressIndicator()
                                        : Text(widget.buttonName),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

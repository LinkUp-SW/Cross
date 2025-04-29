import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/viewModel/comment_vm.dart';
import 'package:link_up/features/Home/viewModel/write_comment_vm.dart';
import 'package:link_up/features/Home/widgets/reactions.dart';
import 'package:link_up/features/Post/widgets/formatted_richtext.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

//TODO: handle child comment replay calling
class CommentBubble extends ConsumerStatefulWidget {
  const CommentBubble({
    super.key,
    this.isReply = false,
    required this.comment,
    this.allRelies = false,
    required this.refresh,
  });

  final CommentModel comment;

  final bool isReply;
  final bool allRelies;
  final Function refresh;

  @override
  ConsumerState<CommentBubble> createState() => _CommentBubbleState();
}

class _CommentBubbleState extends ConsumerState<CommentBubble> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: CircleAvatar(
            radius: 15.r,
            backgroundImage: NetworkImage(widget.comment.header.profileImage,),
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        Flexible(
          flex: widget.isReply ? 9 : 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.isReply) return;
                  ref.read(commentProvider.notifier).setComment(widget.comment);
                  context.push("/commentReplies/unfocused");
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.comment.header.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text:
                                              ' • ${widget.comment.header.connectionDegree}',
                                          style: TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 10.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    widget.comment.header.about,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10.r),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.comment.header.getTime(),
                                  style: TextStyle(fontSize: 10.r),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        useRootNavigator: true,
                                        builder:
                                            (context) => CustomModalBottomSheet(
                                                  content: Column(
                                                    children: [
                                                      if (widget.comment.header
                                                              .userId ==
                                                          InternalEndPoints
                                                              .userId) ...[
                                                        ListTile(
                                                            leading: const Icon(
                                                                Icons.edit),
                                                            title: const Text(
                                                                "Edit Comment"),
                                                            onTap: () {
                                                              ref
                                                                  .read(writeCommentProvider
                                                                      .notifier)
                                                                  .setComment(
                                                                      widget
                                                                          .comment,
                                                                      true);
                                                              context.pop();
                                                            }),
                                                        ListTile(
                                                            leading: const Icon(
                                                                Icons.delete),
                                                            title: const Text(
                                                                "Delete Comment"),
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      backgroundColor: Theme.of(context)
                                                                          .colorScheme
                                                                          .primary,
                                                                      title: const Text(
                                                                          "Delete Comment"),
                                                                      content:
                                                                          const Text(
                                                                              "Are you sure you want to delete this comment?"),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            context.pop();
                                                                          },
                                                                          child:
                                                                              const Text("Cancel"),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            ref.read(commentProvider.notifier).deleteComment(widget.comment.postId,
                                                                                widget.comment.id).then((_){
                                                                                  widget.refresh();
                                                                                });
                                                                            context.pop();
                                                                            context.pop();
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Delete",
                                                                            style:
                                                                                TextStyle(color: AppColors.red),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            }),
                                                      ],
                                                      ListTile(
                                                        onTap: () {
                                                          //TODO: share comment
                                                        },
                                                        leading: const Icon(
                                                            Icons.ios_share),
                                                        title: const Text(
                                                            "Share via"),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          //TODO: report comment
                                                        },
                                                        leading: const Icon(
                                                            Icons.report),
                                                        title: const Text(
                                                            "Report"),
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                  },
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                          ],
                        ),
                        FormattedRichText(
                          text: widget.comment.text,
                          defaultStyle: TextStyle(fontSize: 12.r),
                        ),
                        if (widget.comment.media.type != MediaType.none) ...[
                          SizedBox(
                            height: 10.h,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.network(
                              widget.comment.media.urls[0],
                              fit: BoxFit.fitHeight,
                              height: 120.h,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  Reactions(
                    offset: 80.h,
                    reaction: widget.comment.reaction,
                    setReaction: (reaction) {
                      setState(() {
                      Reaction oldReaction = widget.comment.reaction;
                      if (reaction == Reaction.none) {
                        widget.comment.reaction = Reaction.none;
                        removeReaction(widget.comment.postId, "Comment",commentId: widget.comment.id).then((value) {
                          if (value.isNotEmpty) {
                            widget.comment.likes = value['totalCount'];
                          } else {
                            widget.comment.reaction = oldReaction;
                          }
                          setState(() {});
                        });
                      } else {
                        widget.comment.reaction = reaction;
                        setReaction(widget.comment.postId, reaction, "Comment",commentId: widget.comment.id)
                            .then((value) {
                          if (value.isNotEmpty) {
                            widget.comment.likes = value['totalCount'];
                          } else {
                            widget.comment.reaction = oldReaction;
                          }
                          setState(() {});
                        });
                      }
                    });
                    },
                    child: Text(Reaction.getReactionString(widget.comment.reaction),
                        style: TextStyle(
                            color: widget.comment.reaction == Reaction.none
                                ? AppColors.grey
                                : Reaction.getColor(widget.comment.reaction))),
                  ),
                  if (widget.comment.likes > 0)
                    Text("  •  ${widget.comment.likes} likes",
                        style: const TextStyle(color: AppColors.grey)),
                  if (!widget.isReply) ...[
                    const Text("  |  ",
                        style: TextStyle(color: AppColors.grey)),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(commentProvider.notifier)
                            .setComment(widget.comment);
                        context.push("/commentReplies");
                      },
                      child: const Text(
                        "Reply ",
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ],
                  if (widget.comment.replies > 0)
                    GestureDetector(
                        onTap: () {
                          ref
                              .read(commentProvider.notifier)
                              .setComment(widget.comment);
                          context.push("/commentReplies");
                        },
                        child: Text(
                          " •  ${widget.comment.replies}  ${widget.comment.replies > 1 ? "replies" : "reply"}",
                          style: const TextStyle(color: AppColors.grey),
                        )),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              if (!widget.isReply) ...[
                if (!widget.allRelies) ...[
                  if (widget.comment.replies > 1)
                    TextButton(
                        onPressed: () {
                          ref
                              .read(commentProvider.notifier)
                              .setComment(widget.comment);
                          context.push("/commentReplies");
                        },
                        child: Text(
                          "Show ${widget.comment.replies - 1} more ${widget.comment.replies > 2 ? "replies" : "reply"}",
                        )),
                  if (widget.comment.repliesList.isNotEmpty && !widget.isReply)
                    CommentBubble(
                      refresh: widget.refresh,
                      isReply: true,
                      comment: widget.comment.repliesList[0],
                    ),
                ],
                if (widget.allRelies)
                  Column(
                    children: List.generate(
                      widget.comment.repliesList.length,
                      (index) => Column(
                        children: [
                          CommentBubble(
                            refresh: widget.refresh,
                            isReply: true,
                            comment: widget.comment.repliesList[index],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

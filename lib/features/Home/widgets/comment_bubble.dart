import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/viewModel/comment_vm.dart';
import 'package:link_up/features/Home/widgets/reactions.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';
//TODO: handle child comment replay calling
class CommentBubble extends ConsumerStatefulWidget {
  const CommentBubble({
    super.key,
    this.isReply = false,
    required this.comment,
    this.allRelies = false,
  });

  final CommentModel comment;

  final bool isReply;
  final bool allRelies;

  @override
  ConsumerState<CommentBubble> createState() => _CommentBubbleState();
}

class _CommentBubbleState extends ConsumerState<CommentBubble> {

  Reaction _reaction = Reaction.none;
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: NetworkImage(widget.comment.header.profileImage),
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
                                        builder: (context) =>
                                            CustomModalBottomSheet(
                                              content: Column(
                                                children: [
                                                  ListTile(
                                                    onTap: () {},
                                                    leading: const Icon(
                                                        Icons.ios_share),
                                                    title:
                                                        const Text("Share via"),
                                                  ),
                                                  ListTile(
                                                    onTap: () {},
                                                    leading:
                                                        const Icon(Icons.report),
                                                    title: const Text("Report"),
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
                        Text.rich(
                          TextSpan(
                            text: widget.comment.text,
                            style: TextStyle(fontSize: 12.r),
                          ),
                        ),
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
                    reaction: _reaction,
                    setReaction: (reaction) {
                      setState(() {
                        _reaction = reaction;
                      });
                    },
                    child: Text(Reaction.getReactionString(_reaction), style: TextStyle(color: _reaction == Reaction.none ? AppColors.grey : Reaction.getColor(_reaction))),
                  ),
                  if (widget.comment.likes > 0) Text("  •  ${widget.comment.likes} likes", style: const TextStyle(color: AppColors.grey)),
                  const Text("  |  ", style: TextStyle(color: AppColors.grey)),
                  GestureDetector(
                      onTap: () {
                        ref.read(commentProvider.notifier).setComment(widget.comment);
                        context.push("/commentReplies");
                      }
                    ,child: const Text("Reply ", style: TextStyle(color: AppColors.grey))),
                  if (widget.comment.replies > 0)
                    GestureDetector(
                        onTap: () {
                          ref.read(commentProvider.notifier).setComment(widget.comment);
                          context.push("/commentReplies");
                        },
                        child: Text(
                            " •  ${widget.comment.replies}  ${widget.comment.replies > 1 ? "replies" : "reply"}",style: const TextStyle(color: AppColors.grey),)),
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
                          ref.read(commentProvider.notifier).setComment(widget.comment);
                          context.push("/commentReplies");
                        },
                        child: Text(
                          "Show ${widget.comment.replies - 1} more ${widget.comment.replies > 2 ? "replies" : "reply"}",
                        )),
                  if (widget.comment.replies > 0 && !widget.isReply)
                    CommentBubble(
                      isReply: true,
                      comment: widget.comment,
                    ),
                ],
                if (widget.allRelies)
                  Column(
                    children: List.generate(
                      widget.comment.replies,
                      (index) => Column(
                        children: [
                          CommentBubble(
                            isReply: true,
                            comment: widget.comment,
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

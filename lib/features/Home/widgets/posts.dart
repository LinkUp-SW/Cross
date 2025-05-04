import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/viewModel/reactions_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/post_header.dart';
import 'package:link_up/features/Home/widgets/post_top.dart';
import 'package:link_up/features/Home/widgets/reactions.dart';
import 'package:link_up/features/Post/viewModel/write_post_vm.dart';
import 'package:link_up/features/Post/widgets/formatted_richtext.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';

class Posts extends ConsumerStatefulWidget {
  final bool inFeed;
  final bool showBottom;
  final bool inMessage;
  final PostModel post;
  const Posts(
      {super.key,
      this.showBottom = true,
      this.inFeed = false,
      this.inMessage = false,
      required this.post});

  @override
  ConsumerState<Posts> createState() => _PostsState();
}

class _PostsState extends ConsumerState<Posts> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.inMessage) {
          ref.read(postProvider.notifier).setPost(widget.post);
          context.push('/postPage');
        }
      },
      child: Column(
        children: [
          if (widget.post.activity.show && widget.inFeed)
            Column(
              children: [
                PostTop(
                  isAd: widget.post.isAd,
                  post: widget.post,
                ),
                Divider(
                  indent: 10.w,
                  endIndent: 10.w,
                  thickness: 0,
                  color: AppColors.grey,
                ),
              ],
            ),
          PostHeader(
              post: widget.post,
              inFeed: widget.inFeed,
              inMessage: widget.inMessage,
              showTop: widget.post.activity.show),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              child: FormattedRichText(
                defaultStyle: TextStyle(
                  fontSize: 14.r,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                text: widget.post.text,
                enableReadMore: true,
                readMoreThreshold: 2,
                readMoreText: '...more',
                readLessText: '',
                readMoreStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          if (widget.post.media.type != MediaType.none) ...[
            widget.post.media.getMedia(),
            SizedBox(height: 10.h),
          ],
          if (widget.showBottom) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(reactionsProvider.notifier)
                          .setPost(widget.post.id);
                      context.push("/reactions");
                    },
                    child: Row(
                      children: [
                        Wrap(
                          children: [
                            for (var i = 0;
                                i < widget.post.topReactions.length;
                                i++) ...[
                              Align(
                                widthFactor: 0.7,
                                child: Reaction.getIcon(
                                    widget.post.topReactions[i], 15.r),
                              )
                            ],
                          ],
                        ),
                        SizedBox(width: 5.w),
                        if (widget.post.reactions > 0)
                          Text(widget.post.reactions.toString()),
                      ],
                    ),
                  ),
                  Text.rich(TextSpan(children: [
                    if (widget.post.comments > 0)
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            if (!widget.inMessage) {
                              ref
                                  .read(postProvider.notifier)
                                  .setPost(widget.post);
                              context.push("/postPage");
                            }
                          },
                          child: Text(
                              '${widget.post.comments} comment${widget.post.comments > 1 ? 's' : ''}'),
                        ),
                      ),
                    if (widget.post.comments > 0 && widget.post.reposts > 0)
                      const TextSpan(text: ' • '),
                    if (widget.post.reposts > 0)
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            context.push("/reposts");
                          },
                          child: Text(
                              '${widget.post.reposts} repost${widget.post.reposts > 1 ? 's' : ''}'),
                        ),
                      ),
                  ]))
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Divider(
              indent: 10.w,
              endIndent: 10.w,
              thickness: 0,
              color: AppColors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Reactions(
                  offset: 100.h,
                  reaction: widget.post.reaction,
                  setReaction: (reaction) {
                    setState(() {
                      Reaction oldReaction = widget.post.reaction;
                      if (reaction == Reaction.none) {
                        widget.post.reaction = Reaction.none;
                        removeReaction(widget.post.id, "Post").then((value) {
                          if (value.isNotEmpty) {
                            widget.post.reactions = value['reactions_count'];
                            widget.post.topReactions = value['top_reactions']
                                .map((e) => Reaction.getReaction(e))
                                .toList();
                          } else {
                            widget.post.reaction = oldReaction;
                          }
                          setState(() {});
                        });
                      } else {
                        widget.post.reaction = reaction;
                        setReaction(widget.post.id, reaction, "Post")
                            .then((value) {
                          if (value.isNotEmpty) {
                            log(value.toString());
                            widget.post.reactions = value['reactions_count'];
                            widget.post.topReactions = value['top_reactions']
                                .map((e) => Reaction.getReaction(e))
                                .toList();
                          } else {
                            widget.post.reaction = oldReaction;
                          }
                          setState(() {});
                        });
                      }
                    });
                  },
                  child: SizedBox(
                    width: 60.w,
                    child: Column(
                      children: [
                        Reaction.getIcon(widget.post.reaction, 20.r),
                        Text(
                          Reaction.getReactionString(widget.post.reaction),
                          style: TextStyle(
                            color: Reaction.getColor(widget.post.reaction),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (!widget.inMessage) {
                      ref.read(postProvider.notifier).setPost(widget.post);
                      context.push("/postPage/focused");
                    }
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.comment_outlined),
                      Text('Comment'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => CustomModalBottomSheet(
                        content: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                if (widget.post.media.type == MediaType.post) {
                                  ref.read(writePostProvider.notifier).setMedia(
                                        Media(
                                          type: MediaType.post,
                                          urls: [],
                                          post: widget.post.copyWith(
                                            media: Media.initial(),
                                          ),
                                        ),
                                      );
                                } else {
                                  ref.read(writePostProvider.notifier).setMedia(
                                        Media(
                                            type: MediaType.post,
                                            urls: [],
                                            post: widget.post),
                                      );
                                }
                                context.pop();
                                context.push('/writePost');
                              },
                              leading: const Icon(Icons.edit),
                              title: const Text("Repost with your thoughts"),
                              subtitle: Text(
                                  "Create new post with ${widget.post.header.name} post attached"),
                            ),
                            ListTile(
                              onTap: () {
                                repostInstantly(widget.post.id).then((value) {
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                  openSnackbar(
                                    child: Row(
                                      children: [
                                        Icon(
                                          value
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline,
                                          color: value
                                              ? Theme.of(navigatorKey
                                                      .currentContext!)
                                                  .colorScheme
                                                  .tertiary
                                              : AppColors.red,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          value
                                              ? "Reposted ${widget.post.header.name}'s post"
                                              : "Failed to repost ${widget.post.header.name}'s post",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Theme.of(navigatorKey
                                                    .currentContext!)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                              leading: const Icon(Icons.loop),
                              title: const Text("Repost"),
                              subtitle: Text(
                                  "Instantly bring ${widget.post.header.name} post to others' feeds"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.loop_outlined),
                      Text('Repost'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    shareBottomSheet(context);
                  },
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: -math.pi / 5,
                        child: const Icon(Icons.send_rounded),
                      ),
                      const Text('Share'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (widget.post.activity.show &&
                widget.post.activity.type == ActitvityType.comment)
              Padding(
                padding: EdgeInsets.all(8.r),
                child: CommentBubble(
                    inComments: false,
                    comment: widget.post.activity.comment,
                    refresh: () {}),
              )
          ],
        ],
      ),
    );
  }
}

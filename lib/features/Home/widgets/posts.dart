import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/post_header.dart';
import 'package:link_up/features/Home/widgets/reactions.dart';
import 'package:link_up/features/Post/viewModel/write_post_vm.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';
import 'package:readmore/readmore.dart';

class Posts extends ConsumerStatefulWidget {
  final bool showTop;
  final bool showBottom;
  final bool inMessage;
  final PostModel post;
  const Posts(
      {super.key,
      this.showTop = true,
      this.showBottom = true,
      this.inMessage = false,
      required this.post});

  @override
  ConsumerState<Posts> createState() => _PostsState();
}

class _PostsState extends ConsumerState<Posts> {
  final bool reacted = true;

  bool _following = false;

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
          if (reacted && widget.showTop)
            Column(
              children: [
                PostHeader(
                  isAd: widget.post.isAd,
                  postId: widget.post.id,
                ),
                Divider(
                  indent: 10.w,
                  endIndent: 10.w,
                  thickness: 0,
                  color: AppColors.grey,
                ),
              ],
            ),
          Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 2,
                child: ListTile(
                  leading: !widget.post.isCompany
                      ? CircleAvatar(
                          radius: 20.r,
                          backgroundImage:
                              NetworkImage(widget.post.header.profileImage),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5.r),
                          child: Image.network(widget.post.header.profileImage,
                              width: 40.h, height: 40.h, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          }),
                        ),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.post.header.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (!widget.post.isCompany)
                          TextSpan(
                            text: ' • ${widget.post.header.connectionDegree}',
                            style: TextStyle(
                                color: AppColors.grey, fontSize: 10.r),
                          ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.header.about,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.r, color: AppColors.grey),
                      ),
                      if (!widget.post.isCompany)
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${widget.post.header.getTime()} • ',
                                style: TextStyle(
                                    color: AppColors.grey, fontSize: 10.r),
                              ),
                              if (widget.post.header.edited)
                                TextSpan(
                                  text: 'Edited • ',
                                  style: TextStyle(
                                      color: AppColors.grey, fontSize: 10.r),
                                ),
                              WidgetSpan(
                                child: Icon(
                                  widget.post.header.visibilityPost ==
                                          Visibilities.anyone
                                      ? Icons.public
                                      : Icons.people,
                                  size: 10.r,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: widget.post.header.userId == '1'
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _following = !_following;
                          });
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                              _following ? Icons.check : Icons.add,
                              color: _following ? AppColors.grey : null,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              _following ? 'Following' : 'Follow',
                              style: TextStyle(
                                color: _following ? AppColors.grey : null,
                              ),
                            ),
                          ],
                        ))
                    : Wrap(
                        alignment: WrapAlignment.end,
                        runAlignment: WrapAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              myPostBottomSheet(context,ref,post: widget.post);
                            },
                            icon: const Icon(Icons.more_horiz),
                          ),
                          IconButton(
                            //TODO: Remove post from feed
                            onPressed: () {
                              ref
                                  .read(postsProvider.notifier)
                                  .showUndo(widget.post.id);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              child: ReadMoreText(
                trimExpandedText: '   less',
                trimCollapsedText: 'more    ',
                trimLines: 3,
                trimMode: TrimMode.Line,
                widget.post.text,
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
                      context.push("/reactions");
                    },
                    child: Row(
                      children: [
                        //TODO: Need to change to Like or top reaction depending on the impelementation of the back team
                        Wrap(
                          children: [
                            for (var i = 0; i < 3; i++) ...[
                              Align(
                                widthFactor: 0.7,
                                child:
                                    Reaction.getIcon(Reaction.values[i], 15.r),
                              )
                            ],
                          ],
                        ),
                        SizedBox(width: 5.w),
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
                      widget.post.reaction = reaction;
                    });
                  },
                  child: SizedBox(
                    width: 55.w,
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
                                context.push('/post');
                              },
                              leading: const Icon(Icons.edit),
                              title: const Text("Repost with your thoughts"),
                              subtitle: const Text(
                                  "Create new post with 'name' post attached"),
                            ),
                            ListTile(
                              onTap: () {
                                //TODO: send repost request to backend
                              },
                              leading: const Icon(Icons.loop),
                              title: const Text("Repost"),
                              subtitle: const Text(
                                  "Instantly bring 'name' post to others' feeds"),
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
          ],
        ],
      ),
    );
  }
}

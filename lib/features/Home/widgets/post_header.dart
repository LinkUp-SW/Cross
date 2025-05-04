
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/shared/themes/colors.dart';

class PostHeader extends ConsumerStatefulWidget {
  const PostHeader(
      {super.key,
      required this.post,
      this.inMessage = false,
      this.inFeed = false,
      this.showTop = false});
  final PostModel post;
  final bool inFeed;
  final bool showTop;
  final bool inMessage;

  @override
  ConsumerState<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends ConsumerState<PostHeader> {
  bool _following = false;
  bool _isLoadingFollowing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/profile', extra: widget.post.header.userId);
      },
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: 6,
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
                    WidgetSpan(
                        child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 100.w,
                      ),
                      child: Text(
                        widget.post.header.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.r),
                      ),
                    )),
                    if (!widget.post.isCompany)
                      TextSpan(
                        text: ' • ${widget.post.header.connectionDegree}',
                        style: TextStyle(color: AppColors.grey, fontSize: 10.r),
                      ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.header.about != '')
                    Text(
                      widget.post.isCompany
                          ? '${widget.post.header.followerCount} followers'
                          : widget.post.header.about,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.r, color: AppColors.grey),
                    ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${widget.post.header.getTime()} • ',
                          style:
                              TextStyle(color: AppColors.grey, fontSize: 10.r),
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
          if (!widget.inMessage)
            Flexible(
              flex: 3,
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  !widget.showTop
                      ? Wrap(
                          alignment: WrapAlignment.end,
                          runAlignment: WrapAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.post.header.userId !=
                                        InternalEndPoints.userId
                                    ? aboutPostBottomSheet(context,
                                        post: widget.post)
                                    : myPostBottomSheet(context, ref,
                                        post: widget.post);
                              },
                              icon: const Icon(Icons.more_horiz),
                            ),
                            if (widget.inFeed)
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
                        )
                      : SizedBox(),
                  widget.post.header.userId == InternalEndPoints.userId ||
                          widget.post.header.isFollowing || widget.post.header.connectionDegree == '1st'
                      ? SizedBox()
                      : widget.post.header.followPrimary ||
                              widget.post.isCompany
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoadingFollowing = true; 
                                  if (_following) {
                                    followUser(widget.post.header.userId).then(
                                      (_){
                                        _following = true;
                                        _isLoadingFollowing = false;
                                      }
                                    );
                                  } else {
                                    unfollowUser(widget.post.header.userId).then(
                                      (_){
                                        _following = false;
                                        _isLoadingFollowing = false;
                                      }
                                    );
                                  }
                                });
                              },
                              child: _isLoadingFollowing ? 
                                  SizedBox(
                                    height: 15.h,
                                    width: 15.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5.w,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                  :
                              Wrap(
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
                          : TextButton(
                              onPressed: () {
                                      setState(() {
                                        context.push('/profile', extra: widget.post.header.userId);
                                      });
                                    },
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(
                                    _following
                                        ? Icons.access_time
                                        : Icons.person_add_alt_1,
                                    color: _following ? AppColors.grey : null,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text('Connect',
                                    style: TextStyle(
                                      color: _following ? AppColors.grey : null,
                                    ),
                                  ),
                                ],
                              )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/logIn/viewModel/user_data_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class PostHeader extends ConsumerStatefulWidget {
  const PostHeader({super.key,required this.post});
  final PostModel post;

  @override
  ConsumerState<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends ConsumerState<PostHeader> {

  bool _following = false;
  bool _showFollow = true;
  bool _isConnected = true;
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider);
    return GestureDetector(
      onTap: () {
        //TDOO: navigate to user profile page
        log('userprofile: ${widget.post.header.userId}');
      },
      child: Flex(
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
                        style: TextStyle(color: AppColors.grey, fontSize: 10.r),
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
            child: widget.post.header.userId != user.userId && _isConnected
                ? _showFollow
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _following = !_following;
                            if (_following) {
                              followUser(widget.post.header.userId);
                            } else {
                              unfollowUser(widget.post.header.userId);
                            }
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
                    : TextButton(
                        onPressed: !_following
                            ? () {
                                setState(() {
                                  _following = !_following;
                                  connectToUser(widget.post.header.userId);
                                });
                              }
                            : null,
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
                            Text(
                              _following ? 'Pending' : 'Connect',
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
                          myPostBottomSheet(context, ref, post: widget.post);
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
    );
  }
}

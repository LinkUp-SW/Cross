import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/comments_vm.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/comments_text_field.dart';
import 'package:link_up/features/Home/widgets/posts.dart';

class PostPage extends ConsumerStatefulWidget {
  final bool isAd;
  final bool focused;

  const PostPage({super.key, this.isAd = false, this.focused = false});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final FocusNode _focusNode = FocusNode();
  late ScrollController _scrollController;
  late String postId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.focused ? _focusNode.requestFocus() : _focusNode.unfocus();
    _scrollController = ScrollController()..addListener(scrollListener);
    ref.read(commentsProvider.notifier).clearComments();
    postId = ref.read(postProvider.notifier).getPostId();
    _isLoading = true;
    ref.read(postProvider.notifier).getPost(postId).then((value) {
      ref.read(commentsProvider.notifier).setCommentsFromPost(value);
      setState(() {
        _isLoading = false;
      });
    },);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        ref.watch(commentsProvider)['cursor'] != null && !_isLoading) {
      log('Loading more comments...');
      await ref
          .read(commentsProvider.notifier)
          .fetchComments(postId)
          .then((value) {
        ref.read(commentsProvider.notifier).addComments(value);
      });
      setState(() {});
    }
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
    });
    ref.read(commentsProvider.notifier).clearComments();
    await ref.read(commentsProvider.notifier).fetchComments(postId,cursor: 0).then(
          (value) => ref.read(commentsProvider.notifier).setComments(value),
        );
    log('Comments refreshed');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PostModel post = ref.watch(postProvider).post;
    final List<dynamic> comments = ref.watch(commentsProvider)['comments'];
    setState(() {});

    if(ref.watch(postProvider).isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            ref.read(commentsProvider.notifier).clearComments();
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              InternalEndPoints.userId == post.header.userId ?
              myPostBottomSheet(context, ref, post: post) :
              aboutPostBottomSheet(context, isAd: widget.isAd, post: post);
            },
          )
        ],
      ),
      bottomNavigationBar: post.header.visibilityComments == Visibilities.noOne
          ? null
          : CommentsTextField(
              postId: postId,
              refresh:() => refresh(),
              focusNode: _focusNode,
              buttonName: 'Comment',
            ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => refresh(),
        child: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                children: [
                  Posts(
                      inFeed: false,
                      inMessage: true,
                      post: post),
                  // const Text("Reactions"),
                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: SizedBox(
                  //     height: 40.h,
                  //     child: ListView.separated(
                  //         separatorBuilder: (context, index) => SizedBox(
                  //               width: 10.w,
                  //             ),
                  //         shrinkWrap: true,
                  //         scrollDirection: Axis.horizontal,
                  //         itemCount: 10,
                  //         itemBuilder: (context, index) {
                  //           return SizedBox(
                  //             width: 30.w,
                  //             child: CircleAvatar(
                  //               radius: 15.r,
                  //               backgroundImage: const NetworkImage(
                  //                   'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                  //             ),
                  //           );
                  //         }),
                  //   ),
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Comments"),
                      // TextButton(
                      //   onPressed: () {
                      //     showModalBottomSheet(
                      //       context: context,
                      //       useRootNavigator: true,
                      //       builder: (context) => CustomModalBottomSheet(
                      //         content: Column(
                      //           children: [
                      //             ListTile(
                      //               onTap: () {
                      //                 //TODO: sort on most relevant
                      //               },
                      //               leading: const Icon(Icons.rocket_launch),
                      //               title: const Text("Most Relevant"),
                      //               subtitle: const Text(
                      //                   "See the most relevatant comments"),
                      //             ),
                      //             ListTile(
                      //               onTap: () {
                      //                 //TODO: sort on most recent
                      //               },
                      //               leading:
                      //                   const Icon(Icons.watch_later_rounded),
                      //               title: const Text("Most Recent"),
                      //               subtitle: const Text(
                      //                   "See all comments, the most recent comments are first"),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   child: const Row(
                      //     children: [
                      //       Text("Most relevant",
                      //           style: TextStyle(
                      //             color: AppColors.grey,
                      //           )),
                      //       Icon(
                      //         Icons.arrow_drop_down,
                      //         color: AppColors.grey,
                      //       )
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments.length + 1,
                    separatorBuilder: (context, index) => SizedBox(
                      height: 10.h,
                    ),
                    itemBuilder: (context, index) {
                      if (index == comments.length &&
                          ref.watch(commentsProvider)['cursor'] != null && !_isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                      if (index == comments.length) {
                        return const SizedBox();
                      }
                      return CommentBubble(
                        refresh: refresh,
                        comment: comments[index],
                        focusNode: _focusNode,
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

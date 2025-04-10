import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/comments_vm.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/comments_text_field.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(scrollListener);
    postId = ref.read(postProvider.notifier).getPostId();
    ref.read(commentsProvider.notifier).fetchComments(postId).then((value) {
      ref.read(commentsProvider.notifier).addComments(value);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(commentsProvider.notifier).fetchComments(postId).then((value) {
        ref.read(commentsProvider.notifier).addComments(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PostModel post = ref.watch(postProvider);
    final List<CommentModel> comments = ref.watch(commentsProvider);

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
              aboutPostBottomSheet(context, isAd: widget.isAd, post: post);
            },
          )
        ],
      ),
      bottomNavigationBar: CommentsTextField(
          focusNode: _focusNode,
          focused: widget.focused,
          buttonName: 'Comment',),
      body: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              controller: _scrollController,
              children: [
                Posts(showTop: false, inMessage: true, post: post),
                const Text("Reactions"),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(
                              width: 10.w,
                            ),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 30.w,
                            child: CircleAvatar(
                              radius: 15.r,
                              backgroundImage: const NetworkImage(
                                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                            ),
                          );
                        }),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Comments"),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          builder: (context) => CustomModalBottomSheet(
                            content: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    //TODO: sort on most relevant
                                  },
                                  leading: const Icon(Icons.rocket_launch),
                                  title: const Text("Most Relevant"),
                                  subtitle: const Text(
                                      "See the most relevatant comments"),
                                ),
                                ListTile(
                                  onTap: () {
                                    //TODO: sort on most recent
                                  },
                                  leading:
                                      const Icon(Icons.watch_later_rounded),
                                  title: const Text("Most Recent"),
                                  subtitle: const Text(
                                      "See all comments, the most recent comments are first"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text("Most relevant",
                              style: TextStyle(
                                color: AppColors.grey,
                              )),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.grey,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                if (comments.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: 10.h,
                    ),
                    itemBuilder: (context, index) {
                      if (index == comments.length - 1) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.darkBlue,
                          ),
                        );
                      }
                      return CommentBubble(
                        comment: comments[index],
                      );
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

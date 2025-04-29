import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/viewModel/comment_vm.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/comments_text_field.dart';
import 'package:link_up/shared/themes/colors.dart';

class CommentRepliesPage extends ConsumerStatefulWidget {
  final bool focused;
  const CommentRepliesPage({super.key, this.focused = true});

  @override
  ConsumerState<CommentRepliesPage> createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState extends ConsumerState<CommentRepliesPage> {
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(scrollListener);
    
    widget.focused ? _focusNode.requestFocus() : _focusNode.unfocus();
    _focusNode.addListener(() {
      setState(() {});
    });
    setState(() {
      _isLoading = true;
    });
    ref
        .read(commentProvider.notifier)
        .fetchCommentReplies(
          ref.read(postProvider).id,
          cursor: 0,
        )
        .then((value) {
      ref.read(commentProvider.notifier).setCommentReplies(value);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void scrollListener() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent && ref.watch(commentProvider).cursor != null) {
      ref
          .read(commentProvider.notifier)
          .fetchCommentReplies(
            ref.read(postProvider).id,
            cursor: ref.read(commentProvider).cursor,
          )
          .then((value) {
        ref.read(commentProvider.notifier).addCommentReplies(value);
        setState(() {
          
        });
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
    });
    ref
        .read(commentProvider.notifier)
        .fetchCommentReplies(
          ref.read(postProvider).id,
          cursor: 0,
        )
        .then((value) {
      ref.read(commentProvider.notifier).setCommentReplies(value);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final CommentModel comment = ref.watch(commentProvider).comment;
    final String postId = ref.watch(postProvider).id;
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Comment Replies'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.h),
          child: Column(
            children: [
              Divider(
                indent: 5.w,
                endIndent: 5.w,
                thickness: 0,
                color: AppColors.grey,
              ),
              Padding(
                padding: EdgeInsets.all(5.w).copyWith(left: 15.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Replies on ${comment.header.name}\'s comment',
                    style:
                        TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ))
          : RefreshIndicator(
              color: Theme.of(context).colorScheme.secondary,
              onRefresh: () => refresh(),
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(5.r),
                      child: CommentBubble(
                        refresh: () {},
                        comment: comment,
                        allRelies: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CommentsTextField(
        refresh: () => refresh(),
        commentId: comment.id,
        postId: postId,
        focusNode: _focusNode,
        showSuggestions: false,
        buttonName: 'Reply',
      ),
    );
  }
}

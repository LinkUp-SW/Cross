import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/comment_model.dart';
import 'package:link_up/features/Home/viewModel/comment_vm.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Home/viewModel/write_comment_vm.dart';
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
          ref.read(postProvider).post.id,
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
            ref.read(postProvider).post.id,
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
          ref.read(postProvider).post.id,
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
    final String postId = ref.watch(postProvider).post.id;
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Comment Replies'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            ref.read(writeCommentProvider.notifier).clearWriteComment();
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Column(
            children: [
              Divider(
                indent: 5,
                endIndent: 5,
                thickness: 0,
                color: AppColors.grey,
              ),
              Padding(
                padding: EdgeInsets.all(5).copyWith(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Replies on ${comment.header.name}\'s comment',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: CommentBubble(
                            refresh: () {},
                            comment: comment,
                            allRelies: true,
                            focusNode: _focusNode,
                          ),
                        ),
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

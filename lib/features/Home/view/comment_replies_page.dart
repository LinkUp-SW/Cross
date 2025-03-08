import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/shared/themes/colors.dart';

class CommentRepliesPage extends StatelessWidget {
  const CommentRepliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reposts'),
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
                    'Replies on x comment on this post',
                    style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: const  Scrollbar( child: SingleChildScrollView(child: Card(child: CommentBubble(replies: 5,allRelies: true,)))),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

class PostPage extends StatefulWidget {
  final bool isAd;
  final bool focused;

  const PostPage({super.key, this.isAd = false, this.focused = false});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              aboutPostBottomSheet(context, isAd: widget.isAd);
            },
          )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          border: const BorderDirectional(
              top: BorderSide(color: AppColors.lightGrey, width: 0)),
        ),
        height: _focusNode.hasFocus ? 150.h : 100.h,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {});
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 5.w),
                      itemBuilder: (context, index) {
                        return Chip(label: Text("label $index"));
                      }),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      flex: 1,
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundImage: const NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Flexible(
                      flex: 8,
                      child: TextField(
                        autofocus: widget.focused,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.r),
                          hintText: "leave your thoughts here...",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.lightGrey, width: 0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.r),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.lightGrey, width: 0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.r),
                            ),
                          ),
                        ),
                        controller: _textController,
                      ),
                    ),
                    SizedBox(
                      width: 10.h,
                    ),
                    if (!_focusNode.hasFocus)
                      GestureDetector(
                          onTap: () {},
                          child: const Icon(Icons.alternate_email))
                  ],
                ),
                if (_focusNode.hasFocus)
                  SizedBox(
                    height: 40.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {}, child: const Icon(Icons.image)),
                              SizedBox(
                                width: 10.w,
                              ),
                            GestureDetector(
                                onTap: () {},
                                child: const Icon(Icons.alternate_email))
                          ],
                        ),
                        Wrap(
                          children: [
                            TextButton(
                              onPressed: () {
                                _focusNode.unfocus();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                _focusNode.unfocus();
                              },
                              child: const Text("Post"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: [
                const Posts(
                  showTop: false,
                  inMessage: true,
                ),
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
                                  onTap: () {},
                                  leading: const Icon(Icons.rocket_launch),
                                  title: const Text("Most Relevant"),
                                  subtitle: const Text(
                                      "See the most relevatant comments"),
                                ),
                                ListTile(
                                  onTap: () {},
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
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 30,
                  separatorBuilder: (context, index) => SizedBox(
                    height: 10.h,
                  ),
                  itemBuilder: (context, index) {
                    return const CommentBubble(replies: 5);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

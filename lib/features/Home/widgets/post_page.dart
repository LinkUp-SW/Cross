import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/comment_bubble.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

class PostPage extends StatelessWidget {
  final bool isAd;
  const PostPage({super.key, this.isAd = false});

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
              aboutPostBottomSheet(context, isAd: isAd);
            },
          )
        ],
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
                                color: Colors.grey,
                              )),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
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
                    return CommentBubble(hasReply: index==3);
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

class CommentBubble extends StatelessWidget {
  const CommentBubble({
    super.key,
    this.isReply = false,
    this.replies = 0,
    this.likes = 0,
    this.allRelies = false,
  });

  final int replies;
  final int likes;

  final bool isReply;
  final bool allRelies;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: const NetworkImage(
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        Flexible(
          flex: isReply ? 9 : 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(5.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200.w,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'John Doe',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' • johndoe',
                                        style: TextStyle(color: AppColors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Discrption mckfdm d lfdfdm lfdkf dldf lkfmkf lfk ndbk',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  '2 hours ago',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (context) => CustomModalBottomSheet(
                                        content: Column(
                                          children: [
                                            ListTile(
                                              onTap: () {},
                                              leading:
                                                  const Icon(Icons.ios_share),
                                              title: const Text("Share via"),
                                            ),
                                            ListTile(
                                              onTap: () {},
                                              leading: const Icon(Icons.report),
                                              title: const Text("Report"),
                                            ),
                                          ],
                                        ),
                                      ));
                            },
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                      const Text.rich(TextSpan(
                        text:
                            "Comment this is the comment section fmkmkf flm ff fl flfm flf  flf lfm f flf lsk",
                      )),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  const Text("Like"),
                  if (likes > 0) Text(" • $likes"),
                  const Text(" | "),
                  const Text("Reply"),
                  if (replies > 0)
                    GestureDetector(
                        onTap: () {
                          context.push("/commentReplies");
                        },
                        child: Text(" • $replies  ${replies > 1 ? "replies" : "reply"}")),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              if (!allRelies) ...[
                if (replies > 1)
                  TextButton(
                      onPressed: () {
                        context.push("/commentReplies");
                      },
                      child: Text(
                        "Show ${replies - 1} more ${replies > 2 ? "replies" : "reply"}",
                      )),
                if (replies > 0 && !isReply)
                  const CommentBubble(
                    isReply: true,
                  ),
              ],
              if (allRelies)
                Column(
                  children: List.generate(
                    replies,
                    (index) => Column(
                      children: [
                        const CommentBubble(
                          isReply: true,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

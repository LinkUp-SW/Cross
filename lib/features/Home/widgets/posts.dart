import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/features/Home/widgets/carousel_images.dart';
import 'package:link_up/features/Home/widgets/post_header.dart';
import 'package:link_up/features/Home/widgets/video_player_home.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';
import 'package:readmore/readmore.dart';

class Posts extends StatefulWidget {
  final bool showTop;
  final bool inMessage;
  final String contentType;
  const Posts(
      {super.key,
      this.showTop = true,
      this.inMessage = false,
      this.contentType = 'none'});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final bool reacted = true;

  final String comments = '100 comments';

  final String reposts = '50 reposts';

  bool _following = false;
  final bool _isAd = true;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/post_page');
      },
      child: Column(
        children: [
          if (reacted && widget.showTop)
            Column(
              children: [
                PostHeader(isAd: _isAd),
                Divider(
                  indent: 10.w,
                  endIndent: 10.w,
                  thickness: 0,
                  color: AppColors.grey,
                ),
              ],
            ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.r,
              backgroundImage: const NetworkImage(
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
            ),
            title: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'John Doe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' • johndoe',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            subtitle: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discrption mckfdm d lfdfdm lfdkf dldf lkfmkf lfk',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  '2 hours ago',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            trailing: TextButton(
                onPressed: () {
                  setState(() {
                    _following = !_following;
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
                )),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.r),
            child: const ReadMoreText(
              trimExpandedText: '   less',
              trimCollapsedText: 'more    ',
              trimLines: 3,
              trimMode: TrimMode.Line,
              'Lorem ipsum dolor sit amet,sknf dkdf kdf ndkj fkjfdn kjfd dfj dfjkf dkdf',
            ),
          ),
          SizedBox(height: 10.h),
          if (widget.contentType == 'video')
            const VideoPlayerHome(
                videoUrl:
                    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
          if (widget.contentType == 'image')
            Image.network(
              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
              fit: BoxFit.cover,
            ),
          if (widget.contentType == 'images')
            const CarouselImages(),
          if (widget.contentType != 'none') SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 10.r,
                      child: const Icon(Icons.thumb_up_alt, size: 15,),
                    ),
                    SizedBox(width: 5.w),
                    const Text("400")
                  ],
                ),
                Text.rich(TextSpan(children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        if (!widget.inMessage) {
                          context.push("/post_page");
                        }
                      },
                      child: Text(comments),
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        context.push("/reposts");
                      },
                      child: Text(' • $reposts'),
                    ),
                  ),
                ]))
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Divider(
            indent: 10.w,
            endIndent: 10.w,
            thickness: 0,
            color: AppColors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                onLongPress: () {},
                child: Column(
                  children: [
                    _isLiked
                        ? const Icon(
                            Icons.thumb_up_alt,
                            color: AppColors.darkBlue,
                          )
                        : const Icon(Icons.thumb_up_alt_outlined),
                    const Text('Like'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!widget.inMessage) {
                    context.push("/post_page/focused");
                  }
                },
                child: const Column(
                  children: [
                    Icon(Icons.comment_outlined),
                    Text('Comment'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    builder: (context) => CustomModalBottomSheet(
                      content: Column(
                        children: [
                          ListTile(
                            onTap: () {},
                            leading: const Icon(Icons.edit),
                            title: const Text("Repost with your thoughts"),
                            subtitle: const Text(
                                "Create new post with 'name' post attached"),
                          ),
                          ListTile(
                            onTap: () {},
                            leading: const Icon(Icons.loop),
                            title: const Text("Repost"),
                            subtitle: const Text(
                                "Instantly bring 'name' post to others' feeds"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Column(
                  children: [
                    Icon(Icons.loop_outlined),
                    Text('Repost'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  shareBottomSheet(context);
                },
                child: Column(
                  children: [
                    Transform.rotate(
                      angle: -math.pi / 5,
                      child: const Icon(Icons.send_rounded),
                    ),
                    const Text('Share'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}


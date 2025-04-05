import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Post/viewModel/write_post_vm.dart';
import 'package:link_up/features/Post/widgets/bottom_sheet.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

aboutPostBottomSheet(BuildContext context, {bool isAd = false}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => CustomModalBottomSheet(
      content: Column(
        children: [
          ListTile(
            onTap: () {
              //TODO: save post
            },
            leading: const Icon(Icons.bookmark_border),
            title: const Text("Save"),
          ),
          ListTile(
            onTap: () {
              //TODO: share post
            },
            leading: const Icon(Icons.ios_share),
            title: const Text("Share via"),
          ),
          ListTile(
            onTap: () {
              //TODO:
            },
            leading: const Icon(Icons.visibility_off),
            title: Text(isAd ? "Hide or report this add" : "Not interested"),
          ),
          isAd
              ? ListTile(
                  onTap: () {
                    //TODO:
                  },
                  leading: const Icon(Icons.info),
                  title: const Text("Why am I seeing this ad?"),
                )
              : ListTile(
                  onTap: () {
                    //TODO: unfollow user
                  },
                  leading: Transform.rotate(
                      angle: math.pi / 4,
                      child: const Icon(Icons.control_point_sharp)),
                  title: const Text("Unfollow 'name'"),
                ),
          if (!isAd)
            ListTile(
              onTap: () {
                //TODO: report post
              },
              leading: const Icon(Icons.report),
              title: const Text("Report post"),
            ),
        ],
      ),
    ),
  );
}

myPostBottomSheet(BuildContext context, WidgetRef ref,
    {required PostModel post}) {
  bool featured = false;
  bool save = false;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => StatefulBuilder(
      builder: (context, StateSetter setState) => Padding(
        padding: EdgeInsets.all(10.r),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                //TODO: feature on top of profile
                setState(() {
                  featured = !featured;
                });
              },
              leading: Icon(featured ? Icons.star : Icons.star_border),
              title: const Text("Feature on top of profile"),
            ),
            ListTile(
              onTap: () {
                //TODO: save post
                setState(() {
                  save = !save;
                });
              },
              leading: Icon(save ? Icons.bookmark : Icons.bookmark_border),
              title: const Text("Save"),
            ),
            ListTile(
              onTap: () {
                //TODO: share post
              },
              leading: const Icon(Icons.ios_share),
              title: const Text("Share via"),
            ),
            ListTile(
              onTap: () {
                //TODO: edit post
                ref.read(writePostProvider.notifier).setPost(post, true);
                context.push('/post');
              },
              leading: const Icon(Icons.edit),
              title: const Text("Edit post"),
            ),
            ListTile(
              onTap: () {
                context.pop();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                          title: const Text("Delete post"),
                          content: const Text(
                              "Are you sure you want to delete this post?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                //TODO: Delete post
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: AppColors.red),
                              ),
                            )
                          ],
                        ));
              },
              leading: const Icon(Icons.delete),
              title: const Text("Delete post"),
            ),
            ListTile(
              onTap: () {
                //TODO: who can comment on this post post
                context.pop();
                postVisibiltyBottomSheet(
                  context,
                  (value) {},
                  (value) {
                    ref
                        .read(writePostProvider.notifier)
                        .setVisibilityComment(value);
                  },
                  post.header.visibilityPost,
                  post.header.visibilityComments,
                  showPost: false,
                  showComment: true,
                );
              },
              leading: const Icon(Icons.comment),
              title: const Text("Who can comment on this post?"),
            ),
            ListTile(
              onTap: () {
                //TODO: who cna see this post
                context.pop();
                postVisibiltyBottomSheet(
                  context,
                  (value) {
                    ref
                        .read(writePostProvider.notifier)
                        .setVisibilityPost(value);
                  },
                  (value) {},
                  post.header.visibilityPost,
                  post.header.visibilityComments,
                  showPost: true,
                  showComment: false,
                );
              },
              leading: const Icon(Icons.visibility),
              title: const Text("Who can see this post?"),
            ),
          ],
        ),
      ),
    ),
  );
}

shareBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => CustomModalBottomSheet(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Send as message",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 15.h),
          TextField(
            decoration: InputDecoration(
              hintText: "Search",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(60.r)),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                      width: 10.w,
                    ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 60.w,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundImage: const NetworkImage(
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                        ),
                        const Text("Name this is sparta 2",
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }),
          ),
          const Divider(
            thickness: 0,
            color: AppColors.grey,
          ),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                      width: 10.w,
                    ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 60.w,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundImage: const NetworkImage(
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                        ),
                        const Text("Name this is sparta 2",
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    ),
  );
}

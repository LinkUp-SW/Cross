import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Post/viewModel/write_post_vm.dart';
import 'package:link_up/features/Post/widgets/bottom_sheet.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';
import 'package:share_plus/share_plus.dart';

aboutPostBottomSheet(BuildContext context,
    {bool isAd = false, required PostModel post, bool isAcitvity = false}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) =>
        StatefulBuilder(builder: (context, StateSetter setState) {
      return CustomModalBottomSheet(
        content: Column(
          children: [
            ListTile(
              onTap: () {
                //TODO: save post
                setState(() {
                  post.saved = !post.saved;
                  if (post.saved) {
                    savePost(post.id);
                  } else {
                    unsavePost(post.id);
                  }
                });
              },
              leading:
                  Icon(post.saved ? Icons.bookmark : Icons.bookmark_border),
              title: Text(post.saved ? "Unsave" : "Save"),
            ),
            ListTile(
              onTap: () {
                //TODO: share post
                context.pop();
                Share.shareUri(Uri.parse('https://github.com'));
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
                      //Needs to be changed to top id and name
                      isAcitvity
                          ? unfollowUser(post.activity.actorUserName)
                          : unfollowUser(post.header.userId);
                    },
                    leading: Transform.rotate(
                        angle: math.pi / 4,
                        child: const Icon(Icons.control_point_sharp)),
                    title: Text(
                        "Unfollow ${isAcitvity ? post.activity.actorName : post.header.name}"),
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
      );
    }),
  );
}

myPostBottomSheet(BuildContext context, WidgetRef ref,
    {required PostModel post}) {
  bool featured = false;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => StatefulBuilder(
      builder: (context, StateSetter setState) => Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
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
                  post.saved = !post.saved;
                  if (post.saved) {
                    savePost(post.id);
                  } else {
                    unsavePost(post.id);
                  }
                });
              },
              leading:
                  Icon(post.saved ? Icons.bookmark : Icons.bookmark_border),
              title: Text(post.saved ? "Unsave" : "Save"),
            ),
            ListTile(
              onTap: () {
                //TODO: share post
                context.pop();
                Share.shareUri(Uri.parse('https://github.com'));
              },
              leading: const Icon(Icons.ios_share),
              title: const Text("Share via"),
            ),
            ListTile(
              onTap: () {
                //TODO: edit post
                ref.read(writePostProvider.notifier).setPost(post, true);
                context.pop();
                context.push('/writePost', extra: post.text);
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
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
                                deletePost(post.id).then((response) {
                                  openSnackbar(
                                      child: Row(
                                    children: [
                                      response == 200
                                          ? Icon(Icons.delete,
                                              color: Theme.of(navigatorKey
                                                      .currentContext!)
                                                  .colorScheme
                                                  .tertiary)
                                          : const Icon(
                                              Icons.error,
                                              color: AppColors.red,
                                            ),
                                      const SizedBox(width: 10),
                                      Text(
                                        response == 200
                                            ? "Post deleted successfully"
                                            : "Failed to delete post",
                                        style: TextStyle(
                                          color: Theme.of(
                                                  navigatorKey.currentContext!)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                        ),
                                      )
                                    ],
                                  ));
                                });
                                context.pop();
                                context.go('/');
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
  List<dynamic> users = [];
  Future<void> getUsers(String query) async {
    final BaseService baseService = BaseService();
    await baseService
        .get('api/v1/search/users?query=$query&limit=25&page=1')
        .then((value) {
      if (value.statusCode == 200) {
        final body = jsonDecode(value.body);
        //log('Fetched users: $body');
        users.clear();
        users = body['people'];
      } else {
        log('Failed to fetch users');
      }
    }).catchError((error) {
      log('Error fetching users: $error');
    });
  }

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height *
          0.8, // Limit height to 80% of screen
    ),
    builder: (context) =>
        StatefulBuilder(builder: (context, StateSetter setState) {
      if (users.isEmpty) {
        getUsers(' ').then((value) {
          if (context.mounted) {
            setState(() {});
          }
        });
      }
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // This is the key line that makes it move up with keyboard
        ),
        child: CustomModalBottomSheet(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Send as message",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                onChanged: (value) async {
                  {
                    await getUsers(value);
                    if (context.mounted) {
                      setState(() {});
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).textTheme.bodyLarge!.color!)),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 70,
                child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                          width: 10,
                        ),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          //TODO: navigate to user messages page and send the message
                        },
                        child: SizedBox(
                          width: 60,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(users[index]['profile_photo']),
                              ),
                              Text(users[index]['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              const Divider(
                thickness: 0,
                color: AppColors.grey,
              ),
              SizedBox(
                height: 70,
                child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                          width: 10,
                        ),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: const NetworkImage(
                                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                            ),
                            Text("Name this is sparta 2",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                )),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

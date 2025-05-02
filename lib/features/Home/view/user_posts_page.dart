import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/widgets/posts.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({super.key});

  @override
  State<UserPostsPage> createState() => _RepostsPageState();
}

class _RepostsPageState extends State<UserPostsPage> {
  final List<PostModel> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String userId = InternalEndPoints.userId; // Replace with actual user ID
  String userName = "Salah"; // Replace with actual user name
  int? cursor = 0; // Initialize cursor to 0
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Fetch saved posts when the page is initialized
    getUserPosts(cursor,userId).then((fetchedPosts) {
      setState(() {
        posts.addAll(fetchedPosts.first);
        cursor = fetchedPosts.last;
      });
      isLoading = false;
    }).catchError((error) {
      // Handle error if needed
      log('Error fetching saved posts: $error');
    });
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent && cursor != null) {
        await loadMorePosts();
      }
    });
  } // Assuming you have a function to get saved posts

  Future<void> loadMorePosts() async {
    setState(() {
      isLoadingMore = true;
    });
    await getUserPosts(cursor,userId).then((fetchedPosts) {
      setState(() {
        posts.addAll(fetchedPosts.first);
        cursor = fetchedPosts.last;
        isLoadingMore = false;
      });
    }).catchError((error) {
      // Handle error if needed
      log('Error fetching saved posts: $error');
    });
    return;
  }

  Future<void> refreshPosts() async {
    setState(() {
      isLoading = true;
    });
    await getUserPosts(cursor,userId).then((fetchedPosts) {
      setState(() {
        posts.clear();
        posts.addAll(fetchedPosts.first);
        cursor = fetchedPosts.last;
        isLoading = false;
      });
    }).catchError((error) {
      // Handle error if needed
      log('Error fetching saved posts: $error');
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(userId == InternalEndPoints.userId
            ? 'My Posts'
            : '$userName Posts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Scrollbar(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ))
            : RefreshIndicator(
                color: Theme.of(context).colorScheme.secondary,
                onRefresh: refreshPosts,
                child: posts.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Text(
                            'No user posts yet',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: ListView.separated(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: posts.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            
                            if (index == posts.length && isLoadingMore) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              );
                            }
                            if (index == posts.length) {
                              return const SizedBox.shrink();
                            }
                            return Card(
                              child: Posts(
                                post: posts[index],
                              ),
                            );
                          },
                        ),
                      ),
              ),
      ),
    );
  }
}

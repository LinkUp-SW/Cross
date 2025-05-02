import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/post_functions.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _RepostsPageState();
}

class _RepostsPageState extends State<SavedPostsPage> {
  final List<PostModel> posts = [];
  bool isLoading = true;
  int? cursor = 0; // Initialize cursor to 0
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    // Fetch saved posts when the page is initialized
    getSavedPosts(cursor).then((fetchedPosts) {
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
    await getSavedPosts(cursor).then((fetchedPosts) {
      setState(() {
        log(fetchedPosts.toString());
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
    await getSavedPosts(cursor).then((fetchedPosts) {
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
        title: const Text('Saved Posts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ChoiceChip(
                        label: Text('All'),
                        selected: true,
                        onSelected: (value) {}),
                  ],
                ),
              ),
            ],
          ),
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
                            'No saved posts yet',
                            style: TextStyle(
                              fontSize: 30.sp,
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: ListView.separated(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: posts.length,
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

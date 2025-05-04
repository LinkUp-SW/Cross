import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/features/search/viewModel/search_post_vm.dart';
import 'package:link_up/features/search/viewModel/search_vm.dart';

class SearchPostTab extends ConsumerStatefulWidget {
  const SearchPostTab({super.key});

  @override
  ConsumerState<SearchPostTab> createState() => _RepostsPageState();
}

class _RepostsPageState extends ConsumerState<SearchPostTab> {
  ScrollController scrollController = ScrollController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    // Fetch saved posts when the page is initialized
    ref.read(searchPostProvider.notifier).clearPosts();
    setState(() {
      isLoading = true;
    });
    loadsearchPosts();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          ref.read(searchPostProvider).cursor != null) {
        loadsearchPosts();
      }
    });
  } // Assuming you have a function to get saved posts

  void loadsearchPosts() {
    ref
        .read(searchPostProvider.notifier)
        .loadsearchPosts(ref.read(searchProvider).searchText)
        .then((_) {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      // Handle error if needed
      log('Error fetching saved posts: $error');
    });
  }

  Future<void> refreshPosts() async {
    ref.read(searchPostProvider.notifier).clearPosts();
    await ref
        .read(searchPostProvider.notifier)
        .loadsearchPosts(ref.read(searchProvider).searchText);
    setState(() {
      log('Refreshing posts...');
      log(ref.read(searchPostProvider).posts.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(searchPostProvider).posts;
    final isLoadingMore = ref.watch(searchPostProvider).isLoadingMore;
    return Scaffold(
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
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/images/man_on_chair.svg',
                                height: 200,
                                width: 200,
                              ),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                            ],
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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

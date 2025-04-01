import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/deleted_post.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';
import 'package:link_up/shared/widgets/tab_provider.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController scrollController;
  late ScrollController scrollController2;
  int scrollpostion = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    scrollController2 = ScrollController();
    ref.read(postsProvider.notifier).fetchPosts().then((value) {
      ref.read(postsProvider.notifier).addPosts(value);
      checkInternetConnection();
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      ref.read(postsProvider.notifier).fetchPosts().then((value) {
        ref.read(postsProvider.notifier).addPosts(value);
      });
    }
    if (scrollpostion > scrollController.position.pixels.toInt()) {
      scrollController2.animateTo(scrollController2.position.minScrollExtent,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }

    if (scrollpostion < scrollController.position.pixels.toInt()) {
      scrollController2.animateTo(scrollController2.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }

    scrollpostion = scrollController.position.pixels.toInt();
  }

  void scrollTop() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void checkInternetConnection() {
    InternetAddress.lookup('exmaple.com').then((result) {
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log('connected');
      }
    }).catchError(
      (_) {
        log('Not Connected');
        if (mounted) {
          openSnackbar(
            child: Row(
              children: [
                const Icon(
                  Icons.dangerous,
                  color: AppColors.red,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text("No Internet Connection",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color))
              ],
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PostState> posts = ref.watch(postsProvider);
    ref.listen(currentTabProvider, (previous, current) {
      if (current) {
        scrollTop();
      }
      Future.microtask(() {
        ref.read(currentTabProvider.notifier).state = false;
      });
    });
    return Scaffold(
      body: NestedScrollView(
        controller: scrollController2,
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: CustomAppBar(
              searchBar: const CustomSearchBar(),
              leadingAction: () {
                widget.scaffoldKey.currentState!.openDrawer();
              },
            ),
          )
        ],
        body: Scrollbar(
          controller: scrollController,
          child: RefreshIndicator(
            color: AppColors.darkBlue,
            onRefresh: () async {
              await ref.read(postsProvider.notifier).refreshPosts();
            },
            child: Builder(builder: (context) {
              if (posts.isEmpty) {
                return Skeletonizer(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < 5; i++)
                          Card(
                            child: Posts(
                              post: PostModel.initial(),
                              showTop: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: posts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == posts.length - 1) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkBlue,
                        ),
                      );
                    }
                    return Card(
                        child: !posts[index].showUndo
                            ? Posts(
                                post: posts[index].post,
                              )
                            : DeletedPost(
                                userName: posts[index].post.header.name,
                                id: posts[index].post.id,
                              ));
                  });
            }),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';
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

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PostModel> posts = ref.watch(postsProvider);
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
              actions: [
                IconButton(
                  onPressed: () {
                    context.push('/writePost');
                  },
                  icon: const Icon(Icons.edit_square),
                ),
              ],
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
                        child: Posts(
                      post: posts[index],
                    ));
                  });
            }),
          ),
        ),
      ),
    );
  }
}

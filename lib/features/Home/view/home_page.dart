import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController scrollController;
  late ScrollController scrollController2;
  int scrollpostion = 0;

  List<String> posts = List.generate(5, (index) => 'Item $index');

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    scrollController2 = ScrollController();
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      setState(() {
        posts.addAll(List.generate(5, (index) => 'Inserted $index'));
      });
    }
    if(scrollpostion > scrollController.position.pixels.toInt())
    {
      scrollController2.animateTo(scrollController2.position.minScrollExtent,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }

    if(scrollpostion < scrollController.position.pixels.toInt())
    {
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
    return Scaffold(
      body: NestedScrollView(
        controller: scrollController2,
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: CustomAppBar(
              searchBar: const CustomSearchBar(),
              leadingAction: () {
                context.push('/profile');
              },
              actions: [
                IconButton(
                  //TODO: add the action to write a post
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          )
        ],
        body: Scrollbar(
          controller: scrollController,
          child: ListView.separated(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Card(child: Posts(contentType: index%4 == 1 ? 'video': (index%4 == 2 ? 'image': (index%4 == 3 ? 'images': 'none')),));
              }),
        ),
      ),
    );
  }
}

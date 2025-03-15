import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController scrollController;
  late ScrollController scrollController2;
  int scrollpostion = 0;

  List<PostModel> posts = List.generate(
      5,
      (index) => PostModel(
            id: '1',
            header: HeaderModel(
              profileImage:
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
              name: 'John Doe',
              connectionDegree: 'johndoe',
              about: 'About John Doe',
              timeAgo: DateTime.now(),
              visibility: Visibilities.anyone,
            ),
            text: 'This is a post',
            media: Media(
              type: MediaType.image,
              urls: [
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
              ],
            ),
            reactions: 10,
            comments: 0,
            reposts: 1,
            reaction: Reaction.celebrate,
          ));

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    scrollController2 = ScrollController();
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      setState(() {
        posts.addAll(
          List.generate(
            5,
            (index) => PostModel(
              id: '1',
              header: HeaderModel(
                profileImage:
                    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                name: 'John Doe',
                connectionDegree: 'johndoe',
                about: 'About John Doe',
                timeAgo: DateTime.now(),
                visibility: Visibilities.anyone,
              ),
              text: 'This is a post',
              media: Media(
                type: index % 5 == 1
                    ? MediaType.video
                    : index % 5 == 2
                        ? MediaType.image
                        : index % 5 == 3
                            ? MediaType.images
                            : index % 5 == 4
                                ? MediaType.pdf
                                : MediaType.none,
                urls: index % 5 == 1
                    ? [
                        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4'
                      ]
                    : index % 5 == 2
                        ? [
                            'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
                          ]
                        : index % 5 == 3
                            ? [
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
                                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'
                              ]
                            : index % 5 == 4
                                ? [
                                    'https://www.sldttc.org/allpdf/21583473018.pdf'
                                  ]
                                : [],
              ),
              reactions: 10,
              comments: 50,
              reposts: 0,
              reaction: Reaction.none,
            ),
          ),
        );
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
          child: ListView.separated(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Card(
                    child: Posts(
                  post: posts[index],
                ));
              }),
        ),
      ),
    );
  }
}

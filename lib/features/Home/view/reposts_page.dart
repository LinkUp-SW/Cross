import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/header_model.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';

class RepostsPage extends StatefulWidget {
  const RepostsPage({super.key, this.count = 0});
  final int count;

  @override
  State<RepostsPage> createState() => _RepostsPageState();
}

class _RepostsPageState extends State<RepostsPage> {
  List<PostModel> posts = List.generate(10, (index) => PostModel(
    id: '1',
    header: HeaderModel(
      profileImage: 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      name: 'John Doe',
      connectionDegree: 'johndoe',
      about: 'About John Doe',
      timeAgo: DateTime.now(),
      visibility: Visibilities.anyone,
    ),
    text: 'This is a post',
    media: Media(
      type: MediaType.image,
      urls: ['https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'],
    ),
    reactions: 10,
    comments: 50,
    reposts: 0,
    reaction: Reaction.celebrate,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reposts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.h),
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.count} reposts',
                    style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Card(
                child: Posts(post: posts[index],),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  List<PostModel> posts = List.generate(10, (index) => PostModel.initial());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reposts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Column(
            children: [
              Divider(
                indent: 5,
                endIndent: 5,
                thickness: 0,
                color: AppColors.grey,
              ),
              Padding(
                padding: EdgeInsets.all(5).copyWith(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.count} reposts',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scrollbar(
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
        ),
      ),
    );
  }
}

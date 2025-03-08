import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/widgets/posts.dart';
import 'package:link_up/shared/themes/colors.dart';

class RepostsPage extends StatefulWidget {
  const RepostsPage({super.key, this.count = 0});
  final int count;

  @override
  State<RepostsPage> createState() => _RepostsPageState();
}

class _RepostsPageState extends State<RepostsPage> {
  List<String> posts = List.generate(10, (index) => 'Item $index');

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
                child: Posts(
              contentType: index % 4 == 1
                  ? 'video'
                  : (index % 4 == 2
                      ? 'image'
                      : (index % 4 == 3 ? 'images' : 'none')),
            ));
          },
        ),
      ),
    );
  }
}

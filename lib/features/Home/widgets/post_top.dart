import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/shared/themes/colors.dart';

class PostTop extends ConsumerWidget {
  const PostTop({super.key, required bool isAd, required this.post})
      : _isAd = isAd;

  final bool _isAd;
  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(post.activity.actorProfileImage),
            ),
            SizedBox(
              width: 10,
            ),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 10),
                children: [
                  TextSpan(
                    text: post.activity.actorName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ActitvityType.getActivityTypeString(post.activity.type),
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.end,
          runAlignment: WrapAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                aboutPostBottomSheet(context, isAd: _isAd, post: post,isAcitvity: true);
              },
              icon: const Icon(Icons.more_horiz),
            ),
            IconButton(
              //TODO: delete post action
              onPressed: () {
                ref.read(postsProvider.notifier).showUndo(post.id);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

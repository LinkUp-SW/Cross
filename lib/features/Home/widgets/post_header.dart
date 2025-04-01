

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/shared/themes/colors.dart';

class PostHeader extends ConsumerWidget {
  const PostHeader({
    super.key,
    required bool isAd,
    required this.id
  }) : _isAd = isAd;

  final bool _isAd;
  final String id;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 10.w,
            ),
            for (int i = 0; i < 3; i++)
              Align(
                widthFactor: 0.6,
                child: CircleAvatar(
                  radius: 12.r,
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundImage: const NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                  ),
                ),
              ),
            SizedBox(
              width: 10.w,
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'John Doe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' • johndoe',
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
                aboutPostBottomSheet(context,isAd: _isAd);
              },
              icon: const Icon(Icons.more_horiz),
            ),
            IconButton(
              //TODO: delete post action
              onPressed: () {
                ref.read(postsProvider.notifier).showUndo(id);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/viewModel/posts_vm.dart';
import 'package:link_up/shared/themes/colors.dart';

class DeletedPost extends ConsumerStatefulWidget {
  final String userName;
  final String id;
  const DeletedPost({super.key, required this.userName, required this.id});

  @override
  ConsumerState<DeletedPost> createState() => _DeletedPostState();
}

class _DeletedPostState extends ConsumerState<DeletedPost> {
  @override
  Widget build(BuildContext context) {
    final List<String> buttonTexts = [
      "Not Interested in this topic",
      "Not Interested in ${widget.userName}'s posts",
      "Not appriopriate for LinkUp",
    ];
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    ref.read(postsProvider.notifier).showUndo(widget.id);
                  },
                  child: const Text("Undo")),
            ],
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                color: AppColors.grey,
                thickness: 0,
              ),
              const Text("Tell us more to help imporve your feed",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  )),
              for (int i = 0; i < 3; i++)
                OutlinedButton(
                  onPressed: () {
                    //TODO: send message to backend y removed
                    ref.read(postsProvider.notifier).removePost(widget.id);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(buttonTexts[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

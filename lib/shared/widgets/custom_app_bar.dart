import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final IconData barIcon;
  final List<Widget> actions;
  final Function leadingAction;
  final bool leadingArrow;
  final bool viewMessages;
  const CustomAppBar(
      {super.key,
      required this.barIcon,
      this.actions = const [],
      this.leadingArrow = false,
      this.viewMessages = true,
      required this.leadingAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: leadingArrow == false
          ? GestureDetector(
              onTap: () {
                leadingAction();
              },
              child: CircleAvatar(
                radius: 20.r,
                child: const Image(
                  image: AssetImage("assets/images/profile.png"),
                ),
              ),
            )
          : IconButton(
              onPressed: () {
                leadingAction();
              },
              icon: const Icon(Icons.arrow_back),
            ),
      title: SizedBox(
        height: 35.h,
        child: SearchAnchor.bar(
          suggestionsBuilder:
              (BuildContext context, SearchController searchController) {
            return [
              ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            ];
          },
          barHintText: "Search",
          barLeading: Icon(barIcon),
        ),
      ),
      actions: [
        ...actions,
        viewMessages
            ? IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/messages');
                },
                icon: const Icon(Icons.message),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

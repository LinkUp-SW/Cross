import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget searchBar;
  final List<Widget> actions;
  final Function leadingAction;
  final bool leadingArrow;
  final bool viewMessages;
  const CustomAppBar(
      {super.key,
      required this.searchBar,
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
        child: searchBar,
      ),
      actions: [
        ...actions,
        viewMessages
            ? IconButton(
                onPressed: () {
                  GoRouter.of(context).go('/messages');
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
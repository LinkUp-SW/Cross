import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/viewModel/user_data_vm.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget searchBar;
  final List<Widget> actions;
  final Function leadingAction;
  final bool leadingArrow;
  final bool viewMessages;
  final PreferredSizeWidget? bottom;
  const CustomAppBar(
      {super.key,
      required this.searchBar,
      this.actions = const [],
      this.leadingArrow = false,
      this.viewMessages = true,
      required this.leadingAction,
      this.bottom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: leadingArrow == false
          ? GestureDetector(
              onTap: () {
                leadingAction();
              },
              child: Padding(
                padding: EdgeInsets.all(5.r),
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(userData.profileUrl),
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
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

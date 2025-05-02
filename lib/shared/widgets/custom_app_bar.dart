import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget searchBar;
  final VoidCallback? leadingAction;
  final PreferredSizeWidget? bottom;
  const CustomAppBar({
    super.key,
    required this.searchBar,
    required this.leadingAction,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: GestureDetector(
        onTap: leadingAction,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(InternalEndPoints.profileUrl),
          ),
        ),
      ),
      title: SizedBox(
        height: 35,
        child: searchBar,
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/messages'),
          icon: const Icon(Icons.message),
        )
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

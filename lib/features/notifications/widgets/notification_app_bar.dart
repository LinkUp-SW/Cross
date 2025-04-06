import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/themes/theme_provider.dart';

class NotificationAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomAppBar(
      searchBar: const CustomSearchBar(),
      leadingAction: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          ref.read(themeNotifierProvider.notifier).toggleTheme();
        });
      },
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

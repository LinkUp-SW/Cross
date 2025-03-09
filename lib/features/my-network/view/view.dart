import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/widgets/navigation_row.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class MyNetworkPage extends ConsumerWidget {
  const MyNetworkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              kToolbarHeight + 48.h), // Proper height for app bar + tabs
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomAppBar(
                searchBar: const CustomSearchBar(),
                leadingAction: () {},
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_box_rounded),
                  ),
                ],
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                ),
                child: const TabBar(
                  tabs: [
                    Tab(text: "Grow"),
                    Tab(text: "Catch"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5.h,
              children: [
                NavigationRow(
                  title: 'Invitations',
                  isDarkMode: isDarkMode,
                ),
                NavigationRow(
                  title: 'Manage my network',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            const Center(child: Text("Catch Tab")),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class MyNetworkPage extends ConsumerWidget {
  const MyNetworkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const TabBar(
                tabs: [
                  Tab(text: "Grow"),
                  Tab(text: "Catch"),
                ],
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text("Grow Tab")),
            Center(child: Text("Catch Tab")),
          ],
        ),
      ),
    );
  }
}

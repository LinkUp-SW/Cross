import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/widgets/tab.dart';
import 'package:link_up/shared/themes/colors.dart';
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
              Container(
                color: AppColors.lightMain,
                child: const TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppColors.lightGreen,
                      width: 2.0,
                    ),
                  ),
                  tabs: [
                    CustomTab(title: "Grow"),
                    CustomTab(title: "Catch"),
                    // Tab(text: "Grow"),
                    // Tab(text: "Catch"),
                  ],
                ),
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

  // Widget _buildCustomTab(String text) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(
  //             color: AppColors.lightGrey, // Unselected tab border color
  //             width: 0.5 // Unselected tab border weight
  //             ),
  //       ),
  //     ),
  //     child: Tab(text: text),
  //   );
  // }
}

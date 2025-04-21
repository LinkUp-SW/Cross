import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/search/viewModel/search_vm.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    ref
        .read(searchProvider.notifier)
        .setTabController(TabController(length: 2, vsync: this));
    ref.read(searchProvider.notifier).setSearchController(SearchController());
  }

  @override
  Widget build(BuildContext context) {
    final tabController = ref.watch(searchProvider).tabController;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: SizedBox(
          height: 35.h,
          child: CustomSearchBar(
            inSearch: true,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          Tooltip(
            message: 'Search for jobs',
            child: IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                icon: Icon(
                  Icons.work,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                onPressed: () {
                  //TODO: goto jobs search page
                }),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'People',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            Tab(
              child: Text(
                'Posts',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
          ],
          indicatorColor: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // People tab content
          Center(
            child: Text(
              'People',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          // Posts tab content
          Center(
            child: Text(
              'Posts',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}

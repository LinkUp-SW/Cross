import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/search/model/people_search_card_model.dart';
import 'package:link_up/features/search/viewModel/search_vm.dart';
import 'package:link_up/features/search/widgets/people_search_card.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? searchKeyWord;
  const SearchPage({
    super.key,
    this.searchKeyWord,
  });

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Set up tab controller
    ref
        .read(searchProvider.notifier)
        .setTabController(TabController(length: 2, vsync: this));

    // Create search controller and pre-populate it with searchKeyword
    final searchController = SearchController();
    ref.read(searchProvider.notifier).setSearchController(searchController);

    // Set initial search keyword if provided
    if (widget.searchKeyWord != null && widget.searchKeyWord!.isNotEmpty) {
      // Allow UI to build first, then set the search text
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchController.text = widget.searchKeyWord!;
      });
    }
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) => PeopleSearchCard(
              data: PeopleCardModel(
                  cardId: "1",
                  name: 'Youssef Hassanien',
                  headline: "Software Engineer @ Apple",
                  location: "Cairo, Egypt",
                  profilePhoto: null,
                  connectionDegree: "1st",
                  mutualConnectionsCount: 69,
                  firstMutualConnectionName: "John",
                  firstMutualConnectionPicture: null,
                  isInReceivedConnectionInvitations: false,
                  isInSentConnectionInvitations: false),
              isFirstConnection: true,
              buttonFunctionality: () {},
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

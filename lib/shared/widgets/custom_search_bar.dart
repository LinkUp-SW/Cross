import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/search/viewModel/search_vm.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({
    super.key,
    this.inSearch = false,
  });
  final bool inSearch;

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final searchController = ref.watch(searchProvider).searchController;
    return SearchAnchor.bar(
      searchController: searchController,
      onSubmitted: (value) {
        ref.read(searchProvider.notifier).setSearchText(value);
        ref.read(searchProvider.notifier).search();
        if (!widget.inSearch) {
          context.push('/search');
        } else {
          context.pop();
        }
        searchController.clear();
      },
      suggestionsBuilder:
          (BuildContext context, SearchController searchController) {
        return [
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              itemCount: 40,
              separatorBuilder: (context, index) => SizedBox(width: 5.w),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, index) {
                return CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('$index'),
                );
              },
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (BuildContext context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        ];
      },
      viewTrailing: [
        Icon(
          Icons.qr_code,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
      barHintText: "Search",
      barLeading: const Icon(Icons.search),
      viewLeading: IconButton(
          onPressed: () {
            searchController.clear();
            ref
                .read(searchProvider.notifier)
                .setSearchController(SearchController());
            context.pop();
          },
          icon: const Icon(Icons.arrow_back)),
    );
  }
}

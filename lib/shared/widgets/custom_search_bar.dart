import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/search/viewModel/people_tab_view_model.dart';
import 'package:link_up/features/search/viewModel/search_vm.dart';
import 'package:link_up/features/search/viewModel/suggestions_vm.dart';

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
    final suggestions = ref.watch(suggestionsProvider);
    return SearchAnchor.bar(
      searchController: searchController,
      onChanged: (value) {
        ref.read(suggestionsProvider.notifier).setValue(value);
        ref.read(suggestionsProvider.notifier).getSuggestions(value).then((_) {
          setState(() {
            searchController.text += ' ';
            searchController.text = suggestions['value'];
          });
        });
      },
      onSubmitted: (value) {
        ref.read(suggestionsProvider.notifier).clearSuggestions();
        ref.read(searchProvider.notifier).setSearchText(value);
        ref
            .read(peopleTabViewModelProvider.notifier)
            .getPeopleSearch(queryParameters: {
          "query": value,
          "connectionDegree": "all",
        });
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
            itemCount: suggestions['suggestions'].length,
            itemBuilder: (BuildContext context, index) {
              return suggestions['suggestions'][index].buildSuggestion();
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
            ref.read(suggestionsProvider.notifier).clearSuggestions();
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


import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
      onChanged: (value) async {
        await ref.read(suggestionsProvider.notifier).getSuggestions(value);
        setState(() {
          searchController.text += ' ';
          searchController.text = value;
        });
        log(suggestions.toString());
      },
      onSubmitted: (value) {
        ref.read(searchProvider.notifier).setSearchText(value);
        ref.read(searchProvider.notifier).search();
        if (!widget.inSearch) {
          context.push('/search');
        } else {
          context.pop();
        }
        searchController.clear();
        ref.read(suggestionsProvider.notifier).clearSuggestions();
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
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, index) {
              return suggestions[index].buildSuggestion();
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
            ref.read(suggestionsProvider.notifier).clearSuggestions();
            context.pop();
          },
          icon: const Icon(Icons.arrow_back)),
    );
  }
}

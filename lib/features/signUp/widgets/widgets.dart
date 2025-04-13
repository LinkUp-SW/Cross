//widgets related to this page only
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/signUp/viewModel/past_job_details_provider.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(
          thickness: 1,
          color: Colors.grey,
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: Theme.of(context)
              .colorScheme
              .surface, // Same as background to make it blend
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

enum SearchType { school, company }

class AutocompleteSearchInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final SearchType searchType;

  const AutocompleteSearchInput({
    super.key,
    required this.controller,
    required this.label,
    required this.searchType,
  });

  @override
  ConsumerState<AutocompleteSearchInput> createState() =>
      _AutocompleteSearchInputState();
}

class _AutocompleteSearchInputState
    extends ConsumerState<AutocompleteSearchInput> {
  Timer? _debounce;
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = SearchController();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final notifier = ref.read(pastJobDetailProvider.notifier);
      if (widget.searchType == SearchType.school) {
        notifier.getSchools(query, ref);
      } else {
        notifier.getcompany(query, ref);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.searchType == SearchType.school
        ? ref.watch(schoolResultsProvider)
        : ref.watch(companyResultsProvider);

    return SearchAnchor.bar(
      searchController: _searchController,
      barHintText: widget.label,
      viewLeading: const BackButton(),
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final query = controller.text;
        _onSearchChanged(query);

        final filtered = results
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return List<ListTile>.generate(filtered.length, (int index) {
          final item = filtered[index];
          return ListTile(
            title: Text(item),
            onTap: () {
              widget.controller.text = item;
              controller.closeView(item);
            },
          );
        });
      },
    );
  }
}

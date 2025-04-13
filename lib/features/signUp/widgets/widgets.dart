//widgets related to this page only
import 'dart:async';
import 'dart:developer';

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
  final companydata = [];
  final schooldata = [];

  @override
  void initState() {
    super.initState();

    _searchController = SearchController();
  }

  Future<void> _onSearchChanged(String query) async {
    if (!mounted) return;
    if (widget.searchType == SearchType.school) {
      await ref.read(pastJobDetailProvider.notifier).getSchools(query, ref);
    } else {
      await ref.read(pastJobDetailProvider.notifier).getcompany(query, ref);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final functionstouse = ref.read(pastJobDetailProvider.notifier);
    ref.listen(companyResultsProvider, (context, state) {
      if (state.isEmpty) {
        setState(() {
          companydata.clear();
        });
      } else {
        setState(() {
          companydata.clear();
          companydata.addAll(state);
        });
      }
    });

    ref.listen(schoolResultsProvider, (context, state) {
      if (state.isEmpty) {
        setState(() {
          schooldata.clear();
        });
      } else {
        setState(() {
          schooldata.clear();
          schooldata.addAll(state);
        });
      }
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SearchAnchor.bar(
        searchController: _searchController,
        barHintText: widget.label,
        viewLeading: const BackButton(),
        onChanged: (value) async {
          final query = _searchController.text;
          await _onSearchChanged(query);
          setState(() {
            _searchController.text += ' ';
            _searchController.text = query;
          });
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          return List<ListTile>.generate(
            widget.searchType == SearchType.company
                ? companydata.length
                : schooldata.length,
            (int index) {
              log('ana gowa el builder');
              final data = widget.searchType == SearchType.company
                  ? companydata
                  : schooldata;
              final item = data[index];
              return ListTile(
                title: Text(item['name']),
                onTap: () {
                  widget.controller.text = item['name'];
                  controller.closeView(item['name']);
                  if (widget.searchType == SearchType.company) {
                    functionstouse.saveid(item['_id'], false);
                  } else {
                    functionstouse.saveid(item['_id'], true);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

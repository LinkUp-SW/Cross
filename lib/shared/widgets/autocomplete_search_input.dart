import 'dart:async';
import 'dart:developer';
import 'package:link_up/shared/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AutocompleteSearchInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final Future<List<Map<String, dynamic>>> Function(String query) searchFunction;
  final Function(Map<String, dynamic> selectedItem) onSelected;
  final IconData? icon;

  const AutocompleteSearchInput({
    super.key,
    required this.controller,
    required this.label,
    required this.searchFunction,
    required this.onSelected,
    this.icon,
  });

  @override
  ConsumerState<AutocompleteSearchInput> createState() =>
      _AutocompleteSearchInputState();
}

class _AutocompleteSearchInputState
    extends ConsumerState<AutocompleteSearchInput> {
  Timer? _debounce;
  late final SearchController _searchController;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _searchController.text = widget.controller.text;
  }

  Future<void> _fetchSuggestions(String query) async {
     if (!mounted || query.isEmpty) {
       setState(() {
         _suggestions = [];
         _isLoading = false;
         _error = null;
       });
       if (_searchController.isOpen) _searchController.openView();
       return;
     }

     setState(() {
       _isLoading = true;
       _error = null;
     });

     try {
       final results = await widget.searchFunction(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
          });
        }
     } catch (e) {
        log("Error fetching suggestions: $e");
        if (mounted) {
          setState(() {
             _suggestions = [];
             _error = "Failed to fetch suggestions.";
          });
        }
     } finally {
         if (mounted) {
            setState(() {
              _isLoading = false;
            });
            if (_searchController.isOpen) {
               _searchController.openView();
            }
         }
     }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
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
     if (widget.controller.text != _searchController.text && !_searchController.isOpen) {
        _searchController.text = widget.controller.text;
     }

    return SearchAnchor.bar(
      searchController: _searchController,
      barHintText: widget.label,
      barTrailing: [
        if (widget.controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              widget.controller.clear();
              _searchController.clear();
              setState(() {
                _suggestions = [];
                _error = null;
                _isLoading = false;
              });
              widget.onSelected({});
            },
          )
      ],
      onChanged: (value) {
        widget.controller.text = value;
        _onSearchChanged(value);
      },
      onTap: () {
        if (_searchController.text != widget.controller.text) {
           _searchController.text = widget.controller.text;
           _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
        }
         if (widget.controller.text.isNotEmpty) {
            _fetchSuggestions(widget.controller.text);
         } else {
            setState(() => _suggestions = []);
         }
      },
      viewTrailing: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
             setState(() {
               _suggestions = [];
               _error = null;
               _isLoading = false;
             });
          },
        )
      ],
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        if (_isLoading) {
          return [const ListTile(title: Center(child: CircularProgressIndicator()))];
        }
        if (_error != null) {
           return [ListTile(title: Text(_error!), leading: Icon(Icons.error, color: Colors.red))];
        }
        if (_suggestions.isEmpty && controller.text.isNotEmpty) {
          return [const ListTile(title: Text('No results found'))];
        }
        if (_suggestions.isEmpty && controller.text.isEmpty) {
            return [];
        }

        return List<ListTile>.generate(
          _suggestions.length,
          (int index) {
            final item = _suggestions[index];
            final name = item['name'] ?? 'No Name';
            final logo = item['logo'] as String?;
            final defaultIconData =  Icons.school ;

            return ListTile(
               leading: logo != null && logo.isNotEmpty
                   ? CircleAvatar(
                       backgroundImage: NetworkImage(logo),
                       backgroundColor:  AppColors.lightMain,
                      )
                   : CircleAvatar(
                       backgroundColor: AppColors.lightMain,
                       child: Icon(widget.icon ?? defaultIconData, size: 20),
                      ),
              title: Text(name),
              onTap: () {
                widget.controller.text = name;
                controller.closeView(name);
                widget.onSelected(item);
                 setState(() {
                    _suggestions = [];
                    _error = null;
                 });
              },
            );
          },
        );
      },
    );
  }
}
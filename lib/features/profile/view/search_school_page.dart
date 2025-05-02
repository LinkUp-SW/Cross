import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:link_up/features/signUp/viewModel/past_job_details_provider.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SearchSchoolPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchSchoolPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  ConsumerState<SearchSchoolPage> createState() => _SearchSchoolPageState();
}

class _SearchSchoolPageState extends ConsumerState<SearchSchoolPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
            _fetchResults(widget.initialQuery!);
         }
      });
    }
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
       _fetchResults(query);
    });
  }

  Future<void> _fetchResults(String query) async {
     if (!mounted || query.isEmpty) {
       setState(() {
         _results = [];
         _isLoading = false;
         _error = null;
       });
       return;
     }

     setState(() {
       _isLoading = true;
       _error = null;
     });

     try {
        final notifier = ref.read(pastJobDetailProvider.notifier);
        await notifier.getSchools(query, ref);

        if (mounted) {
          setState(() {
             _results = ref.read(schoolResultsProvider);
             _isLoading = false;
             if (_results.isEmpty) {
                _error = "No schools found.";
             }
          });
        }
     } catch (e) {
        log("Error fetching school suggestions: $e");
        if (mounted) {
          setState(() {
             _isLoading = false;
             _results = [];
             _error = "Failed to fetch suggestions. Please try again.";
          });
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyles.font16_400Weight.copyWith(color: theme.textTheme.bodyLarge?.color),
          cursorColor: theme.colorScheme.secondary,
          decoration: InputDecoration(
            hintText: "Search for school...",
            hintStyle: TextStyles.font16_400Weight.copyWith(color: AppColors.grey),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: theme.iconTheme.color),
              onPressed: () {
                 _searchController.clear();
              },
            ),
        ],
      ),
      body: _buildBody(context, isDarkMode),
    );
  }

  Widget _buildBody(BuildContext context, bool isDarkMode) {
     if (_isLoading) {
       return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary));
     }

     if (_error != null && _results.isEmpty) {
       return Center(
          child: Padding(
             padding: EdgeInsets.all(16),
             child: Text(
               _error!,
               textAlign: TextAlign.center,
               style: TextStyles.font16_500Weight.copyWith(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
             ),
          ),
       );
     }

     if (!_isLoading && _error == null && _results.isEmpty && _searchController.text.isNotEmpty) {
       return Center(
          child: Text(
             'No schools found for "${_searchController.text}"',
             textAlign: TextAlign.center,
             style: TextStyles.font16_500Weight.copyWith(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
          ),
       );
     }

     return ListView.separated(
       itemCount: _results.length,
       separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: isDarkMode ? AppColors.fineLinesGrey : AppColors.lightGrey.withOpacity(0.5),
       ),
       itemBuilder: (context, index) {
          final item = _results[index];
          final name = item['name'] as String? ?? 'Unknown School';
          final logo = item['logo'] as String?;

          return ListTile(
             leading: CircleAvatar(
                radius: 20,
                backgroundColor: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.3),
                backgroundImage: (logo != null && logo.isNotEmpty) ? NetworkImage(logo) : null,
                child: (logo == null || logo.isEmpty)
                    ? Icon(Icons.school, size: 20, color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey)
                    : null,
             ),
             title: Text(
                name,
                style: TextStyles.font15_500Weight.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
             ),
             onTap: () {
                Navigator.pop(context, item);
             },
          );
       },
     );
  }
}
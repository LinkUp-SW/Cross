import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/themes/theme_provider.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/widgets/custom_search_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        searchBar: const CustomSearchBar(),
        leadingAction: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            ref.read(themeNotifierProvider.notifier).toggleTheme();
          });
        },
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text("Hello"),
                selected: true,
                onSelected: (value) {},
              ),
              ChoiceChip(
                label: const Text("Hello"),
                selected: false,
                onSelected: (value) {},
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Open to'),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) => const Skeletonizer(
                        child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.text_snippet),
                        ),
                        title: Text("This is a text"),
                        subtitle: Text("This is the subtitle"),
                        trailing: Icon(Icons.star_border),
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}

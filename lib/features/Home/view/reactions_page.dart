import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReactionsPage extends StatefulWidget {
  const ReactionsPage({super.key});

  @override
  State<ReactionsPage> createState() => _ReactionsPageState();
}

class _ReactionsPageState extends State<ReactionsPage> {
  final Map<String, int> allReactions = {
    'likes': 100,
    'celebrate': 50,
    'support': 30,
    'love': 20,
    'insightful': 10,
    'funny': 5,
  };

  late final int allReactionsCount;

  @override
  void initState() {
    super.initState();
    allReactionsCount = allReactions.values.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: allReactions.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reactions'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.tertiary,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            tabs: [
            Tab(
              text: 'All\n$allReactionsCount',
            ),
            for (var reaction in allReactions.keys)
              Tab(
                icon: const Icon(Icons.thumb_up_alt_outlined),
                text: allReactions[reaction].toString(),
              )
          ]),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: allReactionsCount,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20.r,
                  ),
                  title: Text('Item $index'),
                  subtitle: Text('Item $index'),
                );
              },
            ),
            for (var reaction in allReactions.keys)
              ListView.builder(
                itemCount: allReactions[reaction],
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.r,
                    ),
                    title: Text('Item $index'),
                    subtitle: Text('Item $index'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

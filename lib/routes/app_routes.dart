// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(path:"/", builder:(context, state) => const MyHomePage(title: "Home",)),
        GoRoute(path:"/home", builder:(context, state) => Container()),
        GoRoute(path:"/video", builder:(context, state) => Container()),
        GoRoute(path:"/profile", builder:(context, state) => Container()),
        GoRoute(path:"/login", builder:(context, state) => Container()),
        GoRoute(path:"/signup", builder:(context, state) => Container()),
        GoRoute(path:"/notifications", builder:(context, state) => Container()),
        GoRoute(path:"/jobs", builder:(context, state) => Container()),
        GoRoute(path:"/network", builder:(context, state) => Container()),
        GoRoute(path:"/company", builder:(context, state) => Container()),
        GoRoute(path:"/messages", builder:(context, state) => Container()),
        GoRoute(path:"/chatpage", builder:(context, state) => Container()),

      ]);
});

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool darkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  darkMode = !darkMode;
                });
              },
              icon:
                  Icon(darkMode == false ? Icons.dark_mode : Icons.light_mode))
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
                style: LinkUpButtonStyles().profileOpenToLight(),
                child: const Text('Open to'),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) => Skeletonizer(
                        child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      child: const ListTile(
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


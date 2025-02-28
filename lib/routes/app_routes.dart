// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/view/home_page.dart';
import 'package:link_up/features/Home/widgets/post_page.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/', routes: <RouteBase>[
    GoRoute(path: "/profile", builder: (context, state) => Container()),
    GoRoute(path: "/login", builder: (context, state) => Container()),
    GoRoute(path: "/signup", builder: (context, state) => Container()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell, // The body displays the current screen
        bottomNavigationBar: CustomBottomNavigationBar(
          navigationShell: navigationShell,
        ),
      ),
      branches: <StatefulShellBranch>[
        // The route branch for the first tab of the bottom navigation bar.
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/",
                builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/video",
                builder: (context, state) => const DummyPage(title: 'Video')),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/network",
                builder: (context, state) =>
                    const DummyPage(title: 'My Network')),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/notifications",
                builder: (context, state) =>
                    const DummyPage(title: 'Notifications')),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/jobs",
                builder: (context, state) => const DummyPage(title: 'Jobs')),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/post_page",
                builder: (context, state) => const PostPage()),
          ],
        ),
      ],
    ),
    GoRoute(path: "/company", builder: (context, state) => Container()),
    GoRoute(path: "/messages", builder: (context, state) => const DummyPage(title: "messages")),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

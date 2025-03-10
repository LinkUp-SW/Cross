// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/view/comment_replies_page.dart';
import 'package:link_up/features/Home/view/home_page.dart';
import 'package:link_up/features/Home/view/post_page.dart';
import 'package:link_up/features/Home/view/reactions_page.dart';
import 'package:link_up/features/Home/view/reposts_page.dart';
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
            GoRoute(path: "/", builder: (context, state) => const HomePage()),
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
                builder: (context, state) => const PostPage(),
                routes: [
                  GoRoute(
                    path: '/focused',
                    builder: (context, state) => const PostPage(focused: true),
                  ),
                ]),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/commentReplies",
                builder: (context, state) => const CommentRepliesPage()),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/reposts",
                builder: (context, state) => const RepostsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/reactions",
                builder: (context, state) => const ReactionsPage()),
          ],
        ),
      ],
    ),
    GoRoute(path: "/company", builder: (context, state) => Container()),
    GoRoute(
        path: "/messages",
        builder: (context, state) => const DummyPage(title: "messages")),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

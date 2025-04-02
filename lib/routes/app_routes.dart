// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/view/invitations_screen.dart';
import 'package:link_up/features/my-network/view/manage_my_network_screen.dart';
import 'package:link_up/features/my-network/view/view.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/myhomepage.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/', routes: <RouteBase>[
    GoRoute(path: "/profile", builder: (context, state) => Container()),
    GoRoute(path: "/login", builder: (context, state) => Container()),
    GoRoute(path: "/signup", builder: (context, state) => Container()),
    GoRoute(
      path: "/invitations",
      builder: (context, state) => InvitationsScreen(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
    ),
    GoRoute(
      path: "/manage-network",
      builder: (context, state) => ManageMyNetworkScreen(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
    ),
    GoRoute(
      path: "/connections",
      builder: (context, state) => const DummyPage(
        title: 'Connections Screen',
      ),
    ),
    GoRoute(
      path: "/following",
      builder: (context, state) => const DummyPage(
        title: 'Following Screen',
      ),
    ),
    GoRoute(
      path: "/pages",
      builder: (context, state) => const DummyPage(
        title: 'Pages Screen',
      ),
    ),
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
                builder: (context, state) => const MyHomePage(
                      title: "Home",
                    )),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
              path: "/network",
              builder: (context, state) => const MyNetworkScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(
                path: "/post",
                builder: (context, state) => const DummyPage(title: 'Post')),
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
      ],
    ),
    GoRoute(path: "/company", builder: (context, state) => Container()),
    GoRoute(path: "/messages", builder: (context, state) => Container()),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

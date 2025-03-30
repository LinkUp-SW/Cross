// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/myhomepage.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';
import 'package:link_up/features/profile/view/view.dart';
import 'package:link_up/features/profile/view/edit_intro.dart';
import 'package:link_up/features/profile/view/edit_contact_info.dart';
import 'package:link_up/features/profile/view/add_new_position.dart';
import 'package:link_up/features/profile/view/add_new_education.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/profile', routes: <RouteBase>[
    GoRoute(path: "/profile", builder: (context, state) => const ProfilePage()),
    GoRoute(path: "/login", builder: (context, state) => Container()),
    GoRoute(path: "/signup", builder: (context, state) => Container()),
    //Profile Page Routes
    GoRoute(
      path: "/edit_intro",
      builder: (context, state) => const EditIntroPage(),
    ),
      GoRoute(
      path: "/edit_contact_info",
      builder: (context, state) => const EditContactInfo(),
    ),
      GoRoute(
      path: "/add_new_position",
      builder: (context, state) => const AddNewPosition(),
    ),
      GoRoute(
      path: "/add_new_education",
      builder: (context, state) => const AddNewEducation(),
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
      ],
    ),
    GoRoute(path: "/company", builder: (context, state) => Container()),
    GoRoute(path: "/messages", builder: (context, state) => Container()),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

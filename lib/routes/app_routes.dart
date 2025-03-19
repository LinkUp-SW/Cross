// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/view/view.dart';
import 'package:link_up/features/signUp/view/userInfo/names_view.dart';
import 'package:link_up/features/signUp/view/userInfo/past_job_details.dart';
import 'package:link_up/features/signUp/view/userInfo/take_photo.dart';
import 'package:link_up/features/signUp/view/verification/get_phone_number.dart';
import 'package:link_up/features/signUp/view/verification/signingup_view.dart';
import 'package:link_up/features/signUp/view/verification/verification.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/myhomepage.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/signup/usersname', routes: <RouteBase>[
    GoRoute(path: "/profile", builder: (context, state) => Container()),
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
    GoRoute(
        path: "/signup",
        builder: (context, state) => const SigningupView(),
        routes: [
          GoRoute(
              path: "/usersname",
              builder: (context, state) => const NamingPage()),
          GoRoute(
              path: "/getphone",
              builder: (context, state) => const GetPhoneNumber()),
          GoRoute(
              path: "/verification",
              builder: (context, state) => const Verification()),
          GoRoute(
              path: "/pastjobs",
              builder: (context, state) => const PastJobDetails()),
          GoRoute(
              path: "/takephoto",
              builder: (context, state) => const TakePhoto()),
        ]),
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

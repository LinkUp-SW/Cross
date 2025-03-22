// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/view/comment_replies_page.dart';
import 'package:link_up/features/Home/view/home_page.dart';
import 'package:link_up/features/Home/view/post_page.dart';
import 'package:link_up/features/Home/view/reactions_page.dart';
import 'package:link_up/features/Home/view/reposts_page.dart';
import 'package:link_up/features/Home/view/write_post.dart';
import 'package:link_up/features/notifications/view/notifications_view.dart';
import 'package:link_up/features/my-network/view/invitations.dart';
import 'package:link_up/features/my-network/view/view.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';
import 'package:link_up/shared/widgets/main_drawer.dart';

final goRouterProvider = Provider<GoRouter>((ref) {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
      builder: (context, state) => const DummyPage(
        title: "Manage My Network Screen",
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        key: scaffoldKey,
        drawer: const MainDrawer(),
        body: navigationShell, // The body displays the current screen
        bottomNavigationBar: CustomBottomNavigationBar(
          navigationShell: navigationShell,
        ),
      ),
      branches: <StatefulShellBranch>[
        // The route branch for the first tab of the bottom navigation bar.
        StatefulShellBranch(
          routes: <GoRoute>[
            GoRoute(path: "/", builder: (context, state) => HomePage(scaffoldKey: scaffoldKey,)),
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
                builder: 
                    (context, state) =>NotificationsView(),
        )],
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
                path: "/postPage",
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
                builder: (context, state) => const CommentRepliesPage(),
                routes: [
                  GoRoute(
                    path: '/unfocused',
                    builder: (context, state) => const CommentRepliesPage(focused: false),
                  )]
                  ),
                
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
    GoRoute(path: "/writePost", pageBuilder: (context, state) => 
    CustomTransitionPage(child: const WritePost(), transitionsBuilder: 
    (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    })),
    GoRoute(
        path: "/messages",
        builder: (context, state) => const DummyPage(title: "messages")),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

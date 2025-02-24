// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/myhomepage.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/', routes: <RouteBase>[
    GoRoute(
        path: "/",
        builder: (context, state) => const MyHomePage(
              title: "Home",
            )),
    GoRoute(
        path: "/video",
        builder: (context, state) => const DummyPage(title: 'Video')),
    GoRoute(path: "/profile", builder: (context, state) => Container()),
    GoRoute(path: "/login", builder: (context, state) => Container()),
    GoRoute(path: "/signup", builder: (context, state) => Container()),
    GoRoute(
        path: "/notifications",
        builder: (context, state) => const DummyPage(title: 'Notifications')),
    GoRoute(
        path: "/jobs",
        builder: (context, state) => const DummyPage(title: 'Jobs')),
    GoRoute(
        path: "/network",
        builder: (context, state) => const DummyPage(title: 'My Network')),
    GoRoute(path: "/company", builder: (context, state) => Container()),
    GoRoute(path: "/messages", builder: (context, state) => Container()),
    GoRoute(path: "/chatpage", builder: (context, state) => Container()),
    GoRoute(path: "/settings", builder: (context, state) => Container()),
  ]);
});

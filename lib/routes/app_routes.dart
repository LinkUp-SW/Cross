// The route management packages and the class handling it

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/view/saved_posts.dart';
import 'package:link_up/features/admin_panel/view/statistics_view.dart';
import 'package:link_up/features/my-network/view/connections_screen.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/logIn/view/forgot_pasword_view.dart';
import 'package:link_up/features/logIn/view/login_view.dart';
import 'package:link_up/features/profile/view/view.dart';
import 'package:link_up/features/signUp/view/userInfo/names_view.dart';
import 'package:link_up/features/signUp/view/userInfo/past_job_details.dart';
import 'package:link_up/features/signUp/view/userInfo/take_photo.dart';
import 'package:link_up/features/signUp/view/verification/get_phone_number.dart';
import 'package:link_up/features/signUp/view/verification/email_password_view.dart';
import 'package:link_up/features/signUp/view/verification/otp_view.dart';
import 'package:link_up/features/signUp/view/verification/verification.dart';
import 'package:link_up/features/Home/view/comment_replies_page.dart';
import 'package:link_up/features/Home/view/home_page.dart';
import 'package:link_up/features/Home/view/post_page.dart';
import 'package:link_up/features/Home/view/reactions_page.dart';
import 'package:link_up/features/Home/view/reposts_page.dart';
import 'package:link_up/features/Post/view/write_post.dart';
import 'package:link_up/features/notifications/view/notifications_view.dart';
import 'package:link_up/features/my-network/view/invitations_screen.dart';
import 'package:link_up/features/my-network/view/manage_my_network_screen.dart';
import 'package:link_up/features/my-network/view/people_i_follow_screen.dart';
import 'package:link_up/features/my-network/view/view.dart';
import 'package:link_up/features/chat/view/chat_list_page.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';
import 'package:link_up/features/profile/view/edit_intro.dart';
import 'package:link_up/features/profile/view/edit_contact_info.dart';
import 'package:link_up/features/profile/view/add_new_position.dart';
import 'package:link_up/features/profile/view/add_new_education.dart';
import 'package:link_up/shared/widgets/main_drawer.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/profile',
      routes: <RouteBase>[
        GoRoute(path: "/profile", builder: (context, state) => ProfilePage()),
        GoRoute(
            path: "/login",
            builder: (context, state) => const LoginPage(),
            routes: [
              GoRoute(
                  path: "/forgotpassword",
                  builder: (context, state) => const ForgotPasswordView()),
            ]),
        GoRoute(
            path: '/statistics',
            builder: (context, state) => const StatisticsView()),
        GoRoute(
            path: '/priv',
            builder: (context, state) => const DummyPage(title: 'Users')),
        GoRoute(
            path: "/signup",
            builder: (context, state) => const EmailPasswordView(),
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
              GoRoute(
                  path: "/otp", builder: (context, state) => const OtpView()),
            ]),
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
          builder: (context, state) => ConnectionsScreen(
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        GoRoute(
          path: "/following",
          builder: (context, state) => PeopleIFollowScreen(
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        GoRoute(
          path: "/pages",
          builder: (context, state) => const DummyPage(
            title: 'Pages Screen',
          ),
        ),
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
                GoRoute(
                    path: "/",
                    builder: (context, state) => HomePage(
                          scaffoldKey: scaffoldKey,
                        )),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: "/network",
                  builder: (context, state) => MyNetworkScreen(
                    scaffoldKey: scaffoldKey,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: "/post",
                  redirect: (context, state) => "/writePost",
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: "/notifications",
                  builder: (context, state) => NotificationsView(
                    scaffoldKey: scaffoldKey,
                  ),
                )
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                    path: "/jobs",
                    builder: (context, state) =>
                        const DummyPage(title: 'Jobs')),
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
                        builder: (context, state) =>
                            const PostPage(focused: true),
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
                        builder: (context, state) =>
                            const CommentRepliesPage(focused: false),
                      )
                    ]),
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
            path: "/writePost",
            pageBuilder: (context, state) {
              final text = state.extra as String?;
              return CustomTransitionPage(
                  child: WritePost(text: text ?? ''),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  });
            }),
        GoRoute(
          path: '/savedPosts',
          builder: (context, state) => SavedPostsPage(),
        ),
        GoRoute(
            path: "/messages", builder: (context, state) => ChatListScreen()),
        GoRoute(path: "/chatpage", builder: (context, state) => Container()),
        GoRoute(path: "/settings", builder: (context, state) => Container()),
      ]);
});

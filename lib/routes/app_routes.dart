import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/view/saved_posts.dart';
import 'package:link_up/features/admin_panel/view/dashboard_view.dart';
import 'package:link_up/features/admin_panel/view/privilages_view.dart';
import 'package:link_up/features/Home/view/user_posts_page.dart';
import 'package:link_up/features/admin_panel/view/statistics_view.dart';
import 'package:link_up/features/admin_panel/view/users_view.dart';
import 'package:link_up/features/chat/view/chat_navigation_handler.dart';
import 'package:link_up/features/chat/view/chat_screen.dart';
import 'package:link_up/features/company_profile/view/company_profile_view.dart';
import 'package:link_up/features/my-network/view/connections_screen.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/logIn/view/forgot_pasword_view.dart';
import 'package:link_up/features/logIn/view/login_view.dart';
import 'package:link_up/features/profile/view/education_list_page.dart';
import 'package:link_up/features/profile/view/view.dart';
import 'package:link_up/features/search/view/search_page.dart';
import 'package:link_up/features/jobs/view/search_jobs_page.dart';
import 'package:link_up/features/settings/view/privacy_settings.dart';
import 'package:link_up/features/settings/view/settings.dart';
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
import 'package:link_up/features/subscription/view/view.dart';
import 'package:link_up/shared/dummy_page.dart';
import 'package:link_up/shared/widgets/bottom_navigation_bar.dart';
import 'package:link_up/features/profile/view/edit_intro.dart';
import 'package:link_up/features/profile/view/edit_contact_info.dart';
import 'package:link_up/features/profile/view/add_new_position.dart';
import 'package:link_up/features/profile/view/add_new_education.dart';
import 'package:link_up/shared/widgets/main_drawer.dart';
import 'package:link_up/features/jobs/view/view.dart';
import 'package:link_up/features/profile/view/search_school_page.dart';
import 'package:link_up/features/profile/view/search_organization.dart';
import 'package:link_up/features/profile/view/add_section.dart';
import 'package:link_up/features/profile/view/edit_about.dart';
import 'package:link_up/features/profile/view/add_resume.dart';
import 'package:link_up/features/profile/view/resume_viewer.dart';
import 'package:link_up/features/profile/view/add_new_license.dart';
import 'package:link_up/features/profile/view/add_new_skill.dart';
import 'package:link_up/features/profile/view/skills_list_page.dart';
import 'package:link_up/features/profile/view/experience_list_page.dart';
import 'package:link_up/features/profile/view/license_list_page.dart';
import 'package:link_up/features/profile/view/contact_info.dart';
import 'package:link_up/features/profile/model/profile_model.dart';
import 'package:link_up/features/profile/view/blocked_users_pages.dart';
import 'package:link_up/features/profile/view/add_media_link.dart';
import 'package:link_up/features/jobs/view/job_details.dart';
import 'package:link_up/features/jobs/view/my_jobs_screen.dart';
import 'package:link_up/features/company_profile/view/create_company_view.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/login',
      routes: <RouteBase>[
        GoRoute(
            path: "/profile",
            builder: (context, state) => ProfilePage(
                  userId: state.extra as String,
                )),
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
            path: '/dashboard',
            builder: (context, state) => const DashboardView()),
        GoRoute(path: '/users', builder: (context, state) => const UsersPage()),
        GoRoute(
            path: '/adminjobs',
            builder: (context, state) => const DummyPage(title: 'Admin Jobs')),
        GoRoute(
            path: '/contentModration',
            builder: (context, state) => const ReportsPage()),
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
          builder: (context, state) => InvitationsScreen(),
        ),
        GoRoute(
          path: "/manage-network",
          builder: (context, state) => ManageMyNetworkScreen(),
        ),
        GoRoute(
          path: "/connections",
          builder: (context, state) => ConnectionsScreen(),
        ),
        GoRoute(
          path: "/following",
          builder: (context, state) => PeopleIFollowScreen(),
        ),
        GoRoute(
          path: "/pages",
          builder: (context, state) => const DummyPage(
            title: 'Pages Screen',
          ),
        ),
        //blocked
        GoRoute(
          path: '/blocked_users',
          builder: (context, state) => const BlockedUsersPage(),
        ),

        //Profile Page Routes
        GoRoute(
          path: "/add_profile_section",
          builder: (context, state) => const AddSectionPage(),
        ),
        GoRoute(
          path: "/skills_list_page",
          builder: (context, state) => const SkillListPage(),
        ),
        GoRoute(
          path: "/experience_list_page",
          builder: (context, state) => const ExperienceListPage(),
        ),
        GoRoute(
          path: "/education_list_page",
          builder: (context, state) => const EducationListPage(),
        ),
        GoRoute(
          path: "/license_list_page",
          builder: (context, state) => const LicenseListPage(),
        ),

        GoRoute(
          path: "/add_resume",
          builder: (context, state) => const AddResumePage(),
        ),
        GoRoute(
          path: "/add_new_skill",
          builder: (context, state) => const AddSkillPage(),
        ),
        GoRoute(
          path: "/add_new_license",
          builder: (context, state) => const AddNewLicensePage(),
        ),
        GoRoute(
          path: '/resume_viewer',
          builder: (context, state) {
            final String? resumeUrl = state.extra as String?;
            return ResumeViewerPage(url: resumeUrl);
          },
        ),

        GoRoute(
          path: "/edit_about",
          builder: (context, state) => const EditAboutPage(),
        ),
        GoRoute(
          path: "/add_media_link",
          builder: (context, state) => const AddMediaLinkPage(),
        ),
        GoRoute(
            path: "/search_school",
            pageBuilder: (context, state) {
              final initialQuery = state.extra as String?;
              return MaterialPage(
                fullscreenDialog: true,
                child: SearchSchoolPage(initialQuery: initialQuery),
              );
            }),
        GoRoute(
            path: "/search_organization",
            pageBuilder: (context, state) {
              final initialQuery = state.extra as String?;
              return MaterialPage(
                fullscreenDialog: true,
                child: SearchOrganizationPage(initialQuery: initialQuery),
              );
            }),

        GoRoute(
          path: "/edit_intro",
          builder: (context, state) => const EditIntroPage(),
        ),
        GoRoute(
          path: '/contact_info',
          builder: (context, state) {
            final userProfile = state.extra as UserProfile?;
            if (userProfile == null) {
              return const Scaffold(
                  body:
                      Center(child: Text("Error: User profile data missing.")));
            }
            return ContactInfoPage(userProfile: userProfile);
          },
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
          path: '/company/:companyId',
          builder: (context, state) => CompanyProfileViewPage(
            companyId: state.pathParameters['companyId']!,
          ),
        ),
        GoRoute(
          path: "/add_new_education",
          builder: (context, state) => const AddNewEducation(),
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => Scaffold(
            key: scaffoldKey,
            drawer: const MainDrawer(),
            body: navigationShell,
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
                  redirect: (context, state) => context.push("/writePost"),
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
                  builder: (context, state) => JobsScreen(
                    scaffoldKey: scaffoldKey,
                  ),
                  routes: [
                    GoRoute(
                      path: "details/:jobId",
                      builder: (context, state) {
                        final String jobId = state.pathParameters['jobId']!;
                        return JobDetailsPage(jobId: jobId);
                      },
                    ),
                    GoRoute(
                      path: "/myjobs",
                      builder: (context, state) => const MyJobsScreen(),
                    ),
                    GoRoute(
                      path: "/searchjobs",
                      builder: (context, state) => const SearchJobsPage(),
                    ),
                    GoRoute(
                      path: '/jobs/my-jobs',
                      builder: (context, state) => const MyJobsScreen(),
                    ),

                    // Job Details route
                    GoRoute(
                      path: '/jobs/details/:jobId',
                      builder: (context, state) => JobDetailsPage(
                        jobId: state.pathParameters['jobId']!,
                      ),
                    ),

                    // Job Search route
                    GoRoute(
                      path: 'jobs/search',
                      builder: (context, state) => const SearchJobsPage(),
                    ),
                  ],
                ),
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
            path: '/userPosts',
            builder: (context, state) {
              final extraData = state.extra as Map<String, dynamic>?;
              return UserPostsPage(
                userId: extraData?['userId'] as String? ?? '',
                userName: extraData?['userName'] as String? ?? '',
              );
            }),
        GoRoute(
            path: "/messages", builder: (context, state) => ChatListScreen()),
        GoRoute(
          path: "/chat/:userId",
          builder: (context, state) {
            final String userId = state.pathParameters['userId']!;
            final Map<String, dynamic>? extras =
                state.extra as Map<String, dynamic>?;

            return ChatNavigationHandler(
              userId: userId,
              firstName: extras?['firstName'] ?? '',
              lastName: extras?['lastName'] ?? '',
              profilePic: extras?['profilePic'] ?? '',
            );
          },
        ),
        GoRoute(
          path: "/chatroom/:conversationId",
          builder: (context, state) {
            final String conversationId =
                state.pathParameters['conversationId']!;
            final Map<String, dynamic>? extras =
                state.extra as Map<String, dynamic>?;

            return ChatScreen(
              otheruserid: extras?['otheruserid'] ?? '',
              conversationId: conversationId,
              senderName: extras?['senderName'] ?? '',
              senderProfilePicUrl: extras?['senderProfilePicUrl'] ?? '',
            );
          },
        ),
        GoRoute(path: "/chatpage", builder: (context, state) => Container()),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchPage(
            searchKeyWord: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => SubscriptionManagementScreen(),
        ),
        GoRoute(
            path: "/settings",
            builder: (context, state) => SettingsPage(),
            routes: [
              GoRoute(
                  path: '/privacy',
                  builder: (context, state) => const PrivacySettings()),
            ]),
      ]);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/subscription/model/subscription_card_model.dart';
import 'package:link_up/features/subscription/services/subscription_management_screen_services.dart';
import 'package:link_up/shared/themes/colors.dart';

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({
    super.key,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  bool isPremium = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final currentPlanResponse = await ref
          .read(subscriptionManagementScreenServicesProvider)
          .getCurrentPlan();

      final currentPlan =
          SubscriptionCardModel.fromJson(currentPlanResponse['subscription']);
      currentPlan.plan == "premium"
          ? setState(() {
              isPremium = true;
            })
          : setState(() {
              isPremium = false;
            });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250.w,
                      decoration: const BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundImage:
                                NetworkImage(InternalEndPoints.profileUrl),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                              '${InternalEndPoints.userId.split('-')[0][0].toUpperCase()}${InternalEndPoints.userId.split('-')[0].substring(1)} ${InternalEndPoints.userId.split('-')[1][0].toUpperCase()}${InternalEndPoints.userId.split('-')[1].substring(1)}',
                              style: TextStyle(
                                  fontSize: 20.r, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text('view profile',
                              style: TextStyle(
                                  fontSize: 12.r, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: const Text('X profile viewers'),
                  onTap: () {
                    context.pop();
                    context.push('/profileViews');
                  },
                ),
                ListTile(
                  title: const Text('View all analytics'),
                  onTap: () {
                    context.push('/analytics');
                  },
                ),
                const Divider(color: AppColors.grey, thickness: 0),
                // ListTile(
                //   title: const Text('Puzzle games'),
                //   onTap: () {
                //     context.push('/puzzles');
                //   },
                // ),
                ListTile(
                  title: const Text('Saved posts'),
                  onTap: () {
                    context.push('/savedPosts');
                  },
                ),
                ListTile(
                  title: const Text('Groups'),
                  onTap: () {
                    context.push('/groups');
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Divider(color: AppColors.grey, thickness: 0),
                ListTile(
                  title: Text(
                    isPremium
                        ? 'You are a Premium member'
                        : 'Try Premium for 9.99\$',
                  ),
                  trailing: Image(
                    image: AssetImage(
                      isPremium
                          ? 'assets/images/linkup_premium.png'
                          : 'assets/images/Logo_mini.png',
                    ),
                    width: 25.w,
                    height: 25.h,
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/payment');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    context.pop();
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

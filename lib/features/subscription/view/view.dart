import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/subscription/viewModel/subscription_management_screen_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({
    super.key,
  });

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenScreenState();
}

class _SubscriptionManagementScreenScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    Future.microtask(() {
      ref
          .read(subscriptionManagementScreenViewModelProvider.notifier)
          .getCurrentPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Watch the state to react to changes
    final state = ref.watch(subscriptionManagementScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Subscription Management',
          style: TextStyles.font20_700Weight.copyWith(
            color: isDarkMode ? AppColors.darkGrey : AppColors.lightTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25.w,
            color: isDarkMode
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            height: 40.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Subscription Management',
                  style: TextStyles.font18_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightTextColor,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            height: 40.h,
            child: ListTile(
              title: Text(
                'Curren Plan',
                style: TextStyles.font15_700Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.lightTextColor,
                ),
              ),
              trailing: Text(
                state.currentPlan.plan == 'free' ? 'Regular' : 'Premium',
                style: TextStyles.font14_500Weight.copyWith(
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
          ),
          if (state.currentPlan.plan == 'premium') ...[
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                border: Border(
                  bottom: BorderSide(
                    width: 0.3.w,
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ),
              height: 40.h,
              child: ListTile(
                title: Text(
                  'Subscription Start Date',
                  style: TextStyles.font15_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightTextColor,
                  ),
                ),
                trailing: Text(
                  state.currentPlan.subscriptionStartDate != null
                      ? '${DateTime.parse(state.currentPlan.subscriptionStartDate!).day}-${DateTime.parse(state.currentPlan.subscriptionStartDate!).month}-${DateTime.parse(state.currentPlan.subscriptionStartDate!).year}'
                      : '',
                  style: TextStyles.font14_500Weight.copyWith(
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                border: Border(
                  bottom: BorderSide(
                    width: 0.3.w,
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ),
              height: 40.h,
              child: ListTile(
                title: Text(
                  'Subscription End Date',
                  style: TextStyles.font15_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightTextColor,
                  ),
                ),
                trailing: Text(
                  state.currentPlan.subscriptionEndDate != null
                      ? '${DateTime.parse(state.currentPlan.subscriptionEndDate!).day}-${DateTime.parse(state.currentPlan.subscriptionEndDate!).month}-${DateTime.parse(state.currentPlan.subscriptionEndDate!).year}'
                      : '',
                  style: TextStyles.font14_500Weight.copyWith(
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                border: Border(
                  bottom: BorderSide(
                    width: 0.3.w,
                    color:
                        isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                  ),
                ),
              ),
              height: 40.h,
              child: ListTile(
                title: Text(
                  'Auto Renewal',
                  style: TextStyles.font15_700Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightTextColor,
                  ),
                ),
                trailing: Switch(
                  value: state.currentPlan.autoRenewal != null
                      ? state.currentPlan.autoRenewal!
                      : false,
                  onChanged: (bool value) {},
                  activeColor:
                      isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

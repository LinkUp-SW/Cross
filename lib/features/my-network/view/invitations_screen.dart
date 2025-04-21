import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/view/received_invitations_tab.dart';
import 'package:link_up/features/my-network/view/sent_invitations_tab.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class InvitationsScreen extends ConsumerWidget {
  final bool isDarkMode;
  const InvitationsScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Invitations',
            style: TextStyles.font20_700Weight.copyWith(
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightTextColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: EdgeInsets.symmetric(horizontal: 15.w),
                labelStyle: TextStyles.font13_500Weight,
                unselectedLabelStyle: TextStyles.font13_500Weight,
                labelColor:
                    isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                unselectedLabelColor: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
                tabs: const [
                  Tab(text: "Received"),
                  Tab(text: "Sent"),
                ],
              ),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                color:
                    isDarkMode ? AppColors.darkGrey : AppColors.lightTextColor,
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            ReceivedInvitationsTab(isDarkMode: isDarkMode),
            SentInvitationsTab(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }
}

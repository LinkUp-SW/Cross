import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/section_loading_skeleton.dart';
import 'package:link_up/shared/themes/colors.dart';

class GrowTab extends ConsumerStatefulWidget {
  const GrowTab({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GrowTabState();
}

class _GrowTabState extends ConsumerState<GrowTab> {
  final int paginationLimit = 4;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(growTabViewModelProvider.notifier).getPeopleYouMayKnow(
          queryParameters: {
            "cursor": null,
            "limit": '$paginationLimit',
            "context": "work_experience"
          });
    });

    Future.microtask(() {
      ref.read(growTabViewModelProvider.notifier).getPeopleYouMayKnow(
          queryParameters: {
            "cursor": null,
            "limit": '$paginationLimit',
            "context": "education"
          });
    });

    Future.microtask(() {
      ref.read(growTabViewModelProvider.notifier).getReceivedInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(growTabViewModelProvider);
    return RefreshIndicator(
      color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      onRefresh: () async {
        await ref
            .read(growTabViewModelProvider.notifier)
            .getReceivedInvitations();
        await ref.read(growTabViewModelProvider.notifier).getPeopleYouMayKnow(
            queryParameters: {
              "cursor": null,
              "limit": '$paginationLimit',
              "context": "work_experience"
            });
        await ref.read(growTabViewModelProvider.notifier).getPeopleYouMayKnow(
            queryParameters: {
              "cursor": null,
              "limit": '$paginationLimit',
              "context": "education"
            });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GrowTabNavigationRow(
              title: 'Invitations',
              isDarkMode: isDarkMode,
              onTap: () => context.push('/invitations'),
            ),
            if (state.isLoading && state.receivedInvitations == null)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) =>
                    ReceivedInvitationsCardLoadingSkeleton(),
              )
            else if (state.receivedInvitations != null &&
                state.receivedInvitations!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.receivedInvitations!.length,
                itemBuilder: (context, index) {
                  return ReceivedInvitationsCard(
                    data: state.receivedInvitations!.elementAt(index),
                    onAccept: (userId) {
                      ref
                          .read(growTabViewModelProvider.notifier)
                          .acceptInvitation(userId);
                    },
                    onIgnore: (userId) {
                      ref
                          .read(growTabViewModelProvider.notifier)
                          .ignoreInvitation(userId);
                    },
                  );
                },
              ),
            GrowTabNavigationRow(
              title: 'Manage my network',
              isDarkMode: isDarkMode,
              onTap: () => context.push('/manage-network'),
            ),
            state.isLoading && state.workTitle == null
                ? SectionLoadingSkeleton(
                    title: 'People you may know from Global Solutions Ltd')
                : (state.workTitle != null &&
                        state.peopleYouMayKnowFromWork != null &&
                        state.peopleYouMayKnowFromWork!.isNotEmpty)
                    ? Section(
                        title: "People you may know from ${state.workTitle}",
                        cards: state.peopleYouMayKnowFromWork!
                            .map((person) => PeopleCard(
                                  data: person,
                                  isEducationCard: false,
                                ))
                            .toList())
                    : SizedBox(),
            state.isLoading && state.educationTitle == null
                ? SectionLoadingSkeleton(
                    title: 'People you may know from Global Solutions Ltd')
                : (state.educationTitle != null &&
                        state.peopleYouMayKnowFromEducation != null &&
                        state.peopleYouMayKnowFromEducation!.isNotEmpty)
                    ? Section(
                        title:
                            "People you may know from ${state.educationTitle}",
                        cards: state.peopleYouMayKnowFromEducation!
                            .map((person) => PeopleCard(
                                  data: person,
                                  isEducationCard: true,
                                ))
                            .toList())
                    : SizedBox()
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/newsletter_card.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/wide_people_card.dart';
import 'package:link_up/features/my-network/widgets/wide_section.dart';
import 'package:link_up/shared/themes/colors.dart';

class GrowTab extends ConsumerStatefulWidget {
  const GrowTab({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GrowTabState();
}

class _GrowTabState extends ConsumerState<GrowTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(growTabViewModelProvider.notifier).getReceivedInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(growTabViewModelProvider);

    return RefreshIndicator(
      color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      onRefresh: () async {
        await ref
            .read(growTabViewModelProvider.notifier)
            .getReceivedInvitations();
      },
      child: SingleChildScrollView(
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GrowTabNavigationRow(
              title: 'Invitations',
              onTap: () => context.push('/invitations'),
            ),
            if (state.isLoading && state.receivedInvitations == null)
              ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) =>
                    ReceivedInvitationsLoadingSkeleton(),
              )
            else if (state.receivedInvitations!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: state.receivedInvitations!.length,
                itemBuilder: (context, index) {
                  return ReceivedInvitationsCard(
                    data: state.receivedInvitations![index],
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
              onTap: () => context.push('/manage-network'),
            ),
            Section(
              title: "People you may know based on your recent activity",
              cards: [
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
              ],
            ),
            Section(
              title: "People you may know from Cairo University",
              cards: [
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
              ],
            ),
            WideSection(
              title:
                  "People who are in the Software Development industry also follow these people",
              cards: [
                WidePeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                WidePeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
              ],
            ),
            WideSection(
              title:
                  "People who are in the Software Development industry also subscribe to these newsletters",
              cards: [
                NewsletterCard(
                  data: GrowTabNewsletterCardsModel.initial(),
                ),
                NewsletterCard(
                  data: GrowTabNewsletterCardsModel.initial(),
                ),
              ],
            ),
            Section(
              title: "More suggestions for you",
              cards: [
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
                PeopleCard(
                  data: GrowTabPeopleCardsModel.initial(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

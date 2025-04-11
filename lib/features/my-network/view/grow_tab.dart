import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/features/my-network/viewModel/received_invitations_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/newsletter_card.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/wide_people_card.dart';
import 'package:link_up/features/my-network/widgets/wide_section.dart';

class GrowTab extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const GrowTab({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GrowTabState();
}

class _GrowTabState extends ConsumerState<GrowTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(receivedInvitationsTabViewModelProvider.notifier)
          .getReceivedInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invitationsState = ref.watch(receivedInvitationsTabViewModelProvider);
    // Get invitation count and format title
    final int invitationCount = invitationsState.received?.length ?? 0;
    final String invitationsTitle =
        invitationCount > 0 ? 'Invitations ($invitationCount)' : 'Invitations';

    return ListView(
      children: [
        GrowTabNavigationRow(
          title: invitationsTitle,
          isDarkMode: widget.isDarkMode,
          onTap: () => context.push('/invitations'),
        ),
        SizedBox(
          height: 10.h,
        ),
        GrowTabNavigationRow(
          title: 'Manage my network',
          isDarkMode: widget.isDarkMode,
          onTap: () => context.push('/manage-network'),
        ),
        SizedBox(
          height: 10.h,
        ),
        Section(
          title: "People you may know based on your recent activity",
          cards: [
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
          ],
          isDarkMode: widget.isDarkMode,
        ),
        SizedBox(
          height: 10.h,
        ),
        Section(
          title: "People you may know from Cairo University",
          cards: [
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
          ],
          isDarkMode: widget.isDarkMode,
        ),
        SizedBox(
          height: 10.h,
        ),
        WideSection(
            title:
                "People who are in the Software Development industry also follow these people",
            cards: [
              WidePeopleCard(
                data: GrowTabPeopleCardsModel.initial(),
                isDarkMode: widget.isDarkMode,
              ),
              WidePeopleCard(
                data: GrowTabPeopleCardsModel.initial(),
                isDarkMode: widget.isDarkMode,
              ),
            ],
            isDarkMode: widget.isDarkMode),
        SizedBox(
          height: 10.h,
        ),
        WideSection(
          title:
              "People who are in the Software Development industry also subscribe to these newsletters",
          cards: [
            NewsletterCard(
              data: GrowTabNewsletterCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            NewsletterCard(
              data: GrowTabNewsletterCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
          ],
          isDarkMode: widget.isDarkMode,
        ),
        SizedBox(
          height: 10.h,
        ),
        Section(
          title: "More suggestions for you",
          cards: [
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: widget.isDarkMode,
            ),
          ],
          isDarkMode: widget.isDarkMode,
        ),
      ],
    );
  }
}

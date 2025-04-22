import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/newsletter_card.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/wide_people_card.dart';
import 'package:link_up/features/my-network/widgets/wide_section.dart';

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
            "context": "education"
          });
    });

    Future.microtask(() {
      ref.read(growTabViewModelProvider.notifier).getPeopleYouMayKnow(
          queryParameters: {
            "cursor": null,
            "limit": '$paginationLimit',
            "context": "work_experience"
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(growTabViewModelProvider);
    return ListView(
      children: [
        GrowTabNavigationRow(
          title: 'Invitations',
          isDarkMode: isDarkMode,
          onTap: () => context.push('/invitations'),
        ),
        SizedBox(
          height: 10.h,
        ),
        GrowTabNavigationRow(
          title: 'Manage my network',
          isDarkMode: isDarkMode,
          onTap: () => context.push('/manage-network'),
        ),
        SizedBox(
          height: 10.h,
        ),
        if (state.workTitle != null)
          Section(
            title: "People you may know from ${state.workTitle}",
            cards: state.peopleYouMayKnowFromEducation != null &&
                    state.peopleYouMayKnowFromEducation!.isNotEmpty
                ? state.peopleYouMayKnowFromEducation!
                    .map((person) => PeopleCard(
                          data: person,
                          isDarkMode: isDarkMode,
                        ))
                    .toList()
                : [
                    PeopleCard(
                      data: GrowTabPeopleCardsModel.initial(),
                      isDarkMode: isDarkMode,
                    ),
                    PeopleCard(
                      data: GrowTabPeopleCardsModel.initial(),
                      isDarkMode: isDarkMode,
                    ),
                  ],
            isDarkMode: isDarkMode,
          ),
        SizedBox(
          height: 10.h,
        ),
        Section(
          title: "People you may know from Cairo University",
          cards: [
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
          ],
          isDarkMode: isDarkMode,
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
                isDarkMode: isDarkMode,
              ),
              WidePeopleCard(
                data: GrowTabPeopleCardsModel.initial(),
                isDarkMode: isDarkMode,
              ),
            ],
            isDarkMode: isDarkMode),
        SizedBox(
          height: 10.h,
        ),
        WideSection(
          title:
              "People who are in the Software Development industry also subscribe to these newsletters",
          cards: [
            NewsletterCard(
              data: GrowTabNewsletterCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            NewsletterCard(
              data: GrowTabNewsletterCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
          ],
          isDarkMode: isDarkMode,
        ),
        SizedBox(
          height: 10.h,
        ),
        Section(
          title: "More suggestions for you",
          cards: [
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
            PeopleCard(
              data: GrowTabPeopleCardsModel.initial(),
              isDarkMode: isDarkMode,
            ),
          ],
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/grow_tab_model.dart';
import 'package:link_up/features/my-network/widgets/navigation_row.dart';
import 'package:link_up/features/my-network/widgets/newsletter_card.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/wide_people_card.dart';
import 'package:link_up/features/my-network/widgets/wide_section.dart';

class GrowTab extends ConsumerWidget {
  final bool isDarkMode;

  const GrowTab({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.h,
        children: [
          NavigationRow(
            title: 'Invitations',
            isDarkMode: isDarkMode,
            onTap: () => context.push('/invitations'),
          ),
          NavigationRow(
            title: 'Manage my network',
            isDarkMode: isDarkMode,
            onTap: () => context.push('/manage-network'),
          ),
          Section(
            title: "People you may know based on your recent activity",
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
      ),
    );
  }
}

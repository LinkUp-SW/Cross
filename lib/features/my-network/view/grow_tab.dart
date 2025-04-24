import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/people_card.dart';
import 'package:link_up/features/my-network/widgets/section.dart';
import 'package:link_up/features/my-network/widgets/section_loading_skeleton.dart';

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
        state.isLoading && state.workTitle == null
            ? SectionLoadingSkeleton(
                title: 'People you may know from Global Solutions Ltd')
            : state.workTitle != null &&
                    state.peopleYouMayKnowFromWork!.isNotEmpty
                ? Section(
                    title: "Peope you may know from ${state.workTitle}",
                    cards: state.peopleYouMayKnowFromWork!
                        .map((person) => PeopleCard(
                              data: person,
                            ))
                        .toList())
                : SizedBox(
                    height: 10.h,
                  ),
        state.isLoading && state.educationTitle == null
            ? SectionLoadingSkeleton(
                title: 'People you may know from Global Solutions Ltd')
            : state.educationTitle != null &&
                    state.peopleYouMayKnowFromEducation!.isNotEmpty
                ? Section(
                    title: "Peope you may know from ${state.educationTitle}",
                    cards: state.peopleYouMayKnowFromEducation!
                        .map((person) => PeopleCard(
                              data: person,
                            ))
                        .toList())
                : SizedBox(
                    height: 10.h,
                  ),
      ],
    );
  }
}

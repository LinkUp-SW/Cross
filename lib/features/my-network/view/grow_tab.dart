import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_navigation_row.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_people_card.dart';
import 'package:link_up/features/my-network/widgets/grow_tab_section.dart';

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
        if (state.isLoading == false &&
            state.error == false &&
            state.educationTitle != null &&
            state.peopleYouMayKnowFromEducation!.isNotEmpty)
          Section(
              title: "Peope you may know from ${state.educationTitle}",
              cards: state.peopleYouMayKnowFromEducation!
                  .map((person) => PeopleCard(
                        data: person,
                      ))
                  .toList())
      ],
    );
  }
}

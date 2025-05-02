import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/features/search/viewModel/people_tab_view_model.dart';
import 'package:link_up/features/search/widgets/people_search_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class PeopleTab extends ConsumerStatefulWidget {
  final String keyWord;
  const PeopleTab({
    super.key,
    required this.keyWord,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PeopleTabState();
}

class _PeopleTabState extends ConsumerState<PeopleTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(peopleTabViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(
                  selected: state.currentPeopleDegreeFilter == 'all',
                  backgroundColor:
                      isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  selectedColor:
                      isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                  label: Text(
                    'All',
                    style: TextStyles.font14_500Weight.copyWith(
                        color: state.currentPeopleDegreeFilter == 'all'
                            ? isDarkMode
                                ? AppColors.darkBackground
                                : AppColors.lightBackground
                            : isDarkMode
                                ? AppColors.darkTextColor
                                : AppColors.lightSecondaryText),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': widget.keyWord,
                          'connectionDegree': 'all',
                        },
                      );
                    }
                  },
                ),
                FilterChip(
                  selected: state.currentPeopleDegreeFilter == '1st',
                  backgroundColor:
                      isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  selectedColor:
                      isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                  label: Text(
                    '1st',
                    style: TextStyles.font14_500Weight.copyWith(
                      color: state.currentPeopleDegreeFilter == '1st'
                          ? isDarkMode
                              ? AppColors.darkBackground
                              : AppColors.lightBackground
                          : isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightSecondaryText,
                    ),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': widget.keyWord,
                          'connectionDegree': '1st',
                        },
                      );
                    }
                  },
                ),
                FilterChip(
                  selected: state.currentPeopleDegreeFilter == '2nd',
                  backgroundColor:
                      isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  selectedColor:
                      isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                  label: Text(
                    '2nd',
                    style: TextStyles.font14_500Weight.copyWith(
                      color: state.currentPeopleDegreeFilter == '2nd'
                          ? isDarkMode
                              ? AppColors.darkBackground
                              : AppColors.lightBackground
                          : isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightSecondaryText,
                    ),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': widget.keyWord,
                          'connectionDegree': '2nd',
                        },
                      );
                    }
                  },
                ),
                FilterChip(
                  selected: state.currentPeopleDegreeFilter == '3rd+',
                  backgroundColor:
                      isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                  selectedColor:
                      isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                  label: Text(
                    '3rd+',
                    style: TextStyles.font14_500Weight.copyWith(
                      color: state.currentPeopleDegreeFilter == '3rd+'
                          ? isDarkMode
                              ? AppColors.darkBackground
                              : AppColors.lightBackground
                          : isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightSecondaryText,
                    ),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': widget.keyWord,
                          'connectionDegree': '3rd+',
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Check if user has scrolled to near the end
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200 &&
                  !state.isLoadingMore &&
                  state.currentPage != null) {
                ref.read(peopleTabViewModelProvider.notifier).loadMorePeople(
                  queryParameters: {
                    "query": widget.keyWord,
                    "connectionDegree": state.currentPeopleDegreeFilter,
                    "page": '${state.currentPage! + 1}'
                  },
                );
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      'About ${parseIntegerToCommaSeparatedString(state.peopleCount ?? 0)} results',
                      style: TextStyles.font15_500Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextColor
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ),
                state.isLoading && state.people == null
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              ReceivedInvitationsCardLoadingSkeleton(),
                          childCount: 3,
                        ),
                      )
                    : state.people == null ||
                            state.people!.isEmpty ||
                            state.isError
                        ? SliverToBoxAdapter(
                            child: StandardEmptyListMessage(
                              message: widget.keyWord.isNotEmpty &&
                                      widget.keyWord != " "
                                  ? 'No people found based on ${widget.keyWord}'
                                  : 'Please enter search word',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == state.people!.length) {
                                  // Loading indicator at bottom when loading more
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: isDarkMode
                                            ? AppColors.darkBlue
                                            : AppColors.lightBlue,
                                      ),
                                    ),
                                  );
                                }
                                return PeopleSearchCard(
                                  data: state.people!.elementAt(index),
                                  isFirstConnection: state.people!
                                          .elementAt(index)
                                          .connectionDegree ==
                                      '1st',
                                );
                              },
                              childCount: state.people!.length +
                                  (state.isLoadingMore ? 1 : 0),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

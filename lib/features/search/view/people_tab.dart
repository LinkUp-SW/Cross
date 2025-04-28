import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/widgets/received_invitations_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/features/search/viewModel/people_tab_view_model.dart';
import 'package:link_up/features/search/widgets/people_search_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

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

    Future.microtask(
      () {
        ref.read(peopleTabViewModelProvider.notifier).getPeopleSearch(
          queryParameters: {
            "query": widget.keyWord,
            "connectionDegree": "all",
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(peopleTabViewModelProvider);
    return Column(
      spacing: 20.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
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
                          'query': state.searchKeyWord,
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
                                : AppColors.lightSecondaryText),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': state.searchKeyWord,
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
                                : AppColors.lightSecondaryText),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': state.searchKeyWord,
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
                                : AppColors.lightSecondaryText),
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      ref
                          .read(peopleTabViewModelProvider.notifier)
                          .getPeopleSearch(
                        queryParameters: {
                          'query': state.searchKeyWord,
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
                      notification.metrics.maxScrollExtent - 200) {
                ref.read(peopleTabViewModelProvider.notifier).loadMorePeople();
              }
              return false;
            },
            child: state.isLoading && state.people == null
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) =>
                        ReceivedInvitationsCardLoadingSkeleton(),
                  )
                : state.isError
                    ? RetryErrorMessage(
                        errorMessage:
                            "Failed to load people search based on ${state.searchKeyWord} :(",
                        buttonFunctionality: () async {
                          await ref
                              .read(peopleTabViewModelProvider.notifier)
                              .getPeopleSearch(
                            queryParameters: {
                              "query": widget.keyWord,
                              "connectionDegree":
                                  state.currentPeopleDegreeFilter,
                            },
                          );
                        },
                      )
                    : state.people == null || state.people!.isEmpty
                        ? StandardEmptyListMessage(
                            message:
                                'No people found based on ${state.searchKeyWord}',
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.people!.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.people!.length) {
                                // Show loading indicator at the bottom when loading more
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
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
                                buttonFunctionality: () {},
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }
}

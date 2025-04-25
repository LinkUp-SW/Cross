import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/my-network/viewModel/manage_my_network_screen_view_model.dart';
import 'package:link_up/features/my-network/viewModel/people_i_follow_screen_view_model.dart';
import 'package:link_up/features/my-network/widgets/following_card.dart';
import 'package:link_up/features/my-network/widgets/following_card_loading_skeleton.dart';
import 'package:link_up/features/my-network/widgets/retry_error_message.dart';
import 'package:link_up/features/my-network/widgets/standard_empty_list_message.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class PeopleIFollowScreen extends ConsumerStatefulWidget {
  final int paginationLimit;

  const PeopleIFollowScreen({
    super.key,
    this.paginationLimit = 10,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PeopleIFollowScreenState();
}

class _PeopleIFollowScreenState extends ConsumerState<PeopleIFollowScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      ref
          .read(peopleIFollowScreenViewModelProvider.notifier)
          .getFollowingsCount();
    });

    Future.microtask(
      () {
        ref
            .read(peopleIFollowScreenViewModelProvider.notifier)
            .getFollowingsList(
          {
            'limit': '${widget.paginationLimit}',
            'cursor': null,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(peopleIFollowScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'People I follow',
          style: TextStyles.font20_500Weight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25.w,
            color: isDarkMode
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(manageMyNetworkScreenViewModelProvider.notifier)
                .getManageMyNetworkScreenCounts();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 5.w,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              border: Border(
                bottom: BorderSide(
                  width: 0.3.w,
                  color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                ),
              ),
            ),
            height: 40.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${parseIntegerToCommaSeparatedString(state.followingsCount ?? 0)} people',
                    style: TextStyles.font18_500Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkGrey
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                ref
                    .read(peopleIFollowScreenViewModelProvider.notifier)
                    .loadMoreFollowings(
                        paginationLimit: widget.paginationLimit);
              }
              return false;
            },
            child: Expanded(
                child: state.isLoading && state.followings == null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            FollowingCardLoadingSkeleton(),
                      )
                    : state.isError
                        ? RetryErrorMessage(
                            errorMessage: "Failed to load followings :(",
                            buttonFunctionality: () async {
                              await ref
                                  .read(peopleIFollowScreenViewModelProvider
                                      .notifier)
                                  .getFollowingsList(
                                {
                                  'limit': '${widget.paginationLimit}',
                                  'cursor': null,
                                },
                              );
                            },
                          )
                        : state.followings == null || state.followings!.isEmpty
                            ? StandardEmptyListMessage(message: 'No followings')
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: state.followings!.length +
                                    (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.followings!.length) {
                                    // Show loading indicator at the bottom when loading more
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: isDarkMode
                                              ? AppColors.darkBlue
                                              : AppColors.lightBlue,
                                        ),
                                      ),
                                    );
                                  }
                                  return FollowingCard(
                                    data: state.followings![index],
                                  );
                                },
                              )),
          ),
        ],
      ),
    );
  }
}

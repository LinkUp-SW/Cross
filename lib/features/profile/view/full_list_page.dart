import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';


typedef ItemWidgetBuilder<T> = Widget Function(
    T itemData, bool isDarkMode, BuildContext context, bool isMyProfile);

class FullListPage<T> extends ConsumerWidget {
  final String pageTitle;
  final StateProvider<List<T>?> dataProvider; 
  final ItemWidgetBuilder<T> itemBuilder; 
  final String addRoute; 
  final String? editRoute; 
  final String emptyListMessage; 
  

  const FullListPage({
    super.key,
    required this.pageTitle,
    required this.dataProvider, 
    required this.itemBuilder,
    required this.addRoute, 
    this.editRoute,
    required this.emptyListMessage, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final allItems = ref.watch(dataProvider);
    bool isMyProfile = true; 
    final routeArgs = GoRouterState.of(context).extra;
    if (routeArgs is Map && routeArgs.containsKey('isMyProfile')) {
      isMyProfile = routeArgs['isMyProfile'] as bool? ?? true;
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        elevation: 1, 
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color:
                  isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
          onPressed: () => GoRouter.of(context).pop(), 
        ),
        title: Text(
          pageTitle, 
          style: TextStyles.font18_700Weight.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor),
        ),
        actions: [
          if(isMyProfile)
          IconButton(
            icon: Icon(Icons.add,
                color: isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.lightTextColor),
            tooltip: "Add ${pageTitle.replaceFirst('s', '')}",
            onPressed: () => GoRouter.of(context).push(addRoute), 
          ),
          if (isMyProfile && editRoute != null && allItems != null && allItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.edit,
                  color: isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.lightTextColor,
                  size: 20.sp),
              tooltip: "Edit/Reorder $pageTitle",
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Bulk Edit/Reorder for $pageTitle not implemented yet.')));
              },
            ),
            if (!isMyProfile) SizedBox(width: 48.w)
        ],
      ),
      body: allItems == null
          ? const Center(child: CircularProgressIndicator())
          : allItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      emptyListMessage, 
                      textAlign: TextAlign.center,
                      style: TextStyles.font16_500Weight
                          .copyWith(color: AppColors.lightGrey),
                    ),
                  ))
              : ListView.separated(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return itemBuilder(item, isDarkMode, context, isMyProfile);
                  },
                  separatorBuilder: (context, index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h), 
                    child: Divider(
                      height: 1.h,
                      thickness: 0.5,
                      color: isDarkMode
                          ? AppColors.darkGrey.withOpacity(0.5)
                          : AppColors.lightGrey.withOpacity(0.3),
                    ),
                  ),
                ),
    );
  }
}
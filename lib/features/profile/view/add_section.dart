// profile/view/add_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/profile/widgets/subpages_app_bar.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/profile/viewModel/add_section_view_model.dart';
import 'package:link_up/features/profile/state/add_section_state.dart';
import 'dart:developer';

class SectionItem {
  final String title;
  final String route;
  final IconData? icon;
  final String type;

  SectionItem({required this.title, required this.route, this.icon, required this.type});
}

class AddSectionPage extends ConsumerStatefulWidget {
  const AddSectionPage({super.key});

  @override
  ConsumerState<AddSectionPage> createState() => _AddSectionPageState();
}

class _AddSectionPageState extends ConsumerState<AddSectionPage> {
  bool _isCoreExpanded = true;
  bool _isRecommendedExpanded = true;

  final List<SectionItem> allCoreItems = [
    SectionItem(title: "Add about", route: "/edit_about", icon: Icons.info_outline, type: "about"),
    SectionItem(title: "Add education", route: "/add_new_education", icon: Icons.school_outlined, type: "education"),
    SectionItem(title: "Add position", route: "/add_new_position", icon: Icons.work_outline, type: "position"),
    SectionItem(title: "Add skills", route: "/add_new_skill", icon: Icons.star_outline, type: "skills"),
  ];

  final List<SectionItem> allRecommendedItems = [
    SectionItem(title: "Add resume", route: "/add_resume", icon: Icons.description_outlined, type: "resume"),
    SectionItem(title: "Add licenses & certifications", route: "/add_new_license", icon: Icons.card_membership_outlined, type: "licenses"),
  ];


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final addSectionState = ref.watch(addSectionViewModelProvider);
    log("[AddSectionPage] Build triggered. State: isLoading=${addSectionState.isLoading}, hasAboutInfo=${addSectionState.hasAboutInfo}, hasSkills=${addSectionState.hasSkills}, hasResume=${addSectionState.hasResume}, hasLicenses=${addSectionState.hasLicenses}, error=${addSectionState.error}");

    List<SectionItem> filteredCoreItems = allCoreItems.where((item) {
      if (item.type == "about" && addSectionState.hasAboutInfo) {
        log("[AddSectionPage] Filtering out '${item.title}' because hasAboutInfo is true.");
        return false;
      }
      if (item.type == "skills" && addSectionState.hasSkills) { 
          log("[AddSectionPage] Filtering out '${item.title}' because skills already exist.");
          return false;
       }
      return true;
    }).toList();

    List<SectionItem> filteredRecommendedItems = allRecommendedItems.where((item) {
      if (item.type == "resume" && addSectionState.hasResume) {
        log("[AddSectionPage] Filtering out '${item.title}' because hasResume is true.");
        return false;
      }
      if (item.type == "licenses" && addSectionState.hasLicenses) {
        log("[AddSectionPage] Filtering out '${item.title}' because hasLicenses is true.");
        return false;
      }
      return true;
    }).toList();

    log("[AddSectionPage] Filtered core items count: ${filteredCoreItems.length}");
    log("[AddSectionPage] Filtered recommended items count: ${filteredRecommendedItems.length}");


    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            SubPagesAppBar(
              title: "Add to profile",
              onClosePressed: () => GoRouter.of(context).pop(),
            ),
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                child: addSectionState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : addSectionState.error != null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                "Error loading section status: ${addSectionState.error}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ))
                        : ListView(
                            children: [
                              if (filteredCoreItems.isNotEmpty)
                                _buildExpansionTile(
                                  context: context,
                                  title: "Core",
                                  isExpanded: _isCoreExpanded,
                                  onExpansionChanged: (bool expanded) {
                                    setState(() => _isCoreExpanded = expanded);
                                  },
                                  items: filteredCoreItems,
                                ),
                              if (filteredRecommendedItems.isNotEmpty)
                                _buildExpansionTile(
                                  context: context,
                                  title: "Recommended",
                                  subtitle: "Completing these sections will increase your credibility and give you access to more opportunities",
                                  isExpanded: _isRecommendedExpanded,
                                  onExpansionChanged: (bool expanded) {
                                    setState(() => _isRecommendedExpanded = expanded);
                                  },
                                  items: filteredRecommendedItems,
                                ),
                              if (filteredCoreItems.isEmpty && filteredRecommendedItems.isEmpty && !addSectionState.isLoading)
                                Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Center(
                                      child: Text("All available sections seem to be added!",
                                          style: TextStyles.font16_500Weight.copyWith(color: AppColors.lightGrey),
                                          textAlign: TextAlign.center,
                                        )
                                  ),
                                )
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<SectionItem> items,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryColor = AppColors.lightGrey;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: TextStyles.font18_700Weight.copyWith(color: textColor)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyles.font13_400Weight.copyWith(color: secondaryColor)) : null,
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        iconColor: textColor,
        collapsedIconColor: textColor,
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
        childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h),
        children: items.map((item) => _buildSectionItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildSectionItem(BuildContext context, SectionItem item) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor;
    final iconColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return ListTile(
      leading: item.icon != null
          ? Icon(item.icon, color: iconColor, size: 22.sp)
          : SizedBox(width: 24.w),
      title: Text(item.title, style: TextStyles.font15_500Weight.copyWith(color: textColor)),
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      minLeadingWidth: 10.w,
      dense: true,
      onTap: () {
        try {
          GoRouter.of(context).push(item.route);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not navigate to ${item.route}'), backgroundColor: Colors.red),
          );
          log("Error navigating to ${item.route}: $e");
        }
      },
    );
  }
}